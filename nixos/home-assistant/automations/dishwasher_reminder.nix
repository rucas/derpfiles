{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    actions
    conditions
    triggers
    mkMultiTriggerAutomation
    ;

  phone = entities.people.lucas.mobile;
  tag = "dishwasher-reminder";

  reminderTime = "21:00:00";
  startedAction = "DISHWASHER_STARTED";

  nagIntervalMinutes = 20;
  nagLimit = 6;

  # Zigbee2MQTT retains the last payload, so Home Assistant replays it on every
  # restart and broker reconnect. Without this the replay would re-arm the flag
  # long after the press. Mirrors the guard in the aqara_mini_switch_t1
  # blueprint, and relies on `advanced.last_seen: ISO_8601`.
  maxPressAgeSeconds = 10;

  freshPress = ''
    {{ trigger.payload_json.last_seen is not defined
       or (now().timestamp()
           - (trigger.payload_json.last_seen | as_datetime | as_timestamp))
          < ${toString maxPressAgeSeconds} }}
  '';

  armed = conditions.state {
    entity_id = entities.dishwasher.needsRunning;
    state = "on";
  };

  firedBy = id: {
    condition = "trigger";
    inherit id;
  };

  startedButton = {
    actions = [
      {
        action = startedAction;
        title = "Started it";
      }
    ];
  };
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "dishwasher_reminder";
      alias = "Dishwasher Reminder";
      description = "Nags at 9 PM until the dishwasher gets started.";
      # Parallel, not queued: the bedtime branch runs a repeat loop for up to
      # two hours, and a queued clear would sit behind it instead of dismissing.
      mode = "parallel";
      triggers = [
        (
          triggers.mqtt {
            topic = entities.dishwasher.topic;
            value_template = "{{ value_json.action | default('') }}";
            payload = "single";
          }
          // {
            id = "button";
          }
        )
        (
          triggers.state {
            entity_id = entities.dishwasher.needsRunning;
            to = "on";
          }
          // {
            id = "armed";
          }
        )
        (
          triggers.state {
            entity_id = entities.dishwasher.needsRunning;
            to = "off";
          }
          // {
            id = "cleared";
          }
        )
        (triggers.time reminderTime // { id = "bedtime"; })
        {
          platform = "event";
          event_type = "mobile_app_notification_action";
          event_data.action = startedAction;
          id = "started";
        }
      ];
      action = [
        {
          choose = [
            # Single press on the Aqara mini switch by the dishwasher arms the
            # reminder. Turn on rather than toggle, so a stray second press
            # can't silently disarm it.
            {
              conditions = [
                (firedBy "button")
                (conditions.template freshPress)
              ];
              sequence = [
                {
                  action = "input_boolean.turn_on";
                  target.entity_id = entities.dishwasher.needsRunning;
                }
              ];
            }
            # Silent on arming: lands in Notification Center with no banner or
            # sound, so it reads as ambient state rather than an interruption.
            {
              conditions = [ (firedBy "armed") ];
              sequence = [
                (actions.notifyMobile {
                  service = phone;
                  inherit tag;
                  title = "Dishwasher";
                  message = "Loaded — reminder set for 9 PM";
                  interruptionLevel = "passive";
                })
              ];
            }
            {
              conditions = [ (firedBy "cleared") ];
              sequence = [
                (actions.clearNotification {
                  service = phone;
                  inherit tag;
                })
              ];
            }
            # Tapping "Started it" only drops the flag; the resulting off-state
            # fires the `cleared` branch above, which dismisses the notification.
            {
              conditions = [ (firedBy "started") ];
              sequence = [
                {
                  action = "input_boolean.turn_off";
                  target.entity_id = entities.dishwasher.needsRunning;
                }
              ];
            }
            # Time-sensitive so it breaks through a sleep Focus, and reuses the
            # tag so each re-ping replaces the last rather than stacking.
            {
              conditions = [
                (firedBy "bedtime")
                armed
              ];
              sequence = [
                # Every ping carries the action. iOS only reveals it on a
                # long-press, so it costs nothing on the banner, and dismissing
                # from the first reminder beats waiting out an interval.
                (actions.notifyMobile {
                  service = phone;
                  inherit tag;
                  title = "Dishwasher";
                  message = "Start the dishwasher";
                  interruptionLevel = "time-sensitive";
                  data = startedButton;
                })
                {
                  repeat = {
                    sequence = [
                      { delay.minutes = nagIntervalMinutes; }
                      # Bails out when the flag cleared mid-delay, so a
                      # dismissed reminder never pings again. Nothing follows
                      # the repeat, so halting here ends the run cleanly.
                      armed
                      (actions.notifyMobile {
                        service = phone;
                        inherit tag;
                        title = "Dishwasher";
                        message = "Did you start it?";
                        interruptionLevel = "time-sensitive";
                        data = startedButton;
                      })
                    ];
                    until = [
                      (conditions.template "{{ repeat.index >= ${toString nagLimit} }}")
                    ];
                  };
                }
              ];
            }
          ];
        }
      ];
    })
  ];
}
