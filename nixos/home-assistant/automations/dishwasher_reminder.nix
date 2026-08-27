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

  defaultBedtime = "21:00:00";
  startedAction = "DISHWASHER_STARTED";

  bedtimeUnset = "{{ states('${entities.bedtime}') in ['unknown', 'unavailable'] }}";

  nagIntervalMinutes = 15;
  nagLimit = 8;

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
      description = "Nags at bedtime until the dishwasher gets started.";
      # Parallel, not queued: the bedtime branch runs a repeat loop for up to
      # two hours, and a queued clear would sit behind it instead of dismissing.
      mode = "parallel";
      triggers = [
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
        (triggers.time entities.bedtime // { id = "bedtime"; })
        {
          platform = "event";
          event_type = "mobile_app_notification_action";
          event_data.action = startedAction;
          id = "started";
        }
        (triggers.homeAssistantStart // { id = "startup"; })
      ];
      action = [
        {
          "if" = [ (conditions.template bedtimeUnset) ];
          "then" = [
            {
              action = "input_datetime.set_datetime";
              target.entity_id = entities.bedtime;
              data.time = defaultBedtime;
            }
          ];
        }
        {
          choose = [
            # Silent on arming: lands in Notification Center with no banner or
            # sound, so it reads as ambient state rather than an interruption.
            {
              conditions = [ (firedBy "armed") ];
              sequence = [
                (actions.notifyMobile {
                  service = phone;
                  inherit tag;
                  title = "Dishwasher";
                  message = "Loaded — reminder set for bedtime";
                  interruptionLevel = "passive";
                  data = startedButton;
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
            # tag so each re-ping replaces the last rather than stacking. The
            # delay sits after the notify, so clearing mid-cycle exits the loop
            # at the next check without firing again.
            {
              conditions = [
                (firedBy "bedtime")
                armed
              ];
              sequence = [
                {
                  repeat = {
                    sequence = [
                      (actions.notifyMobile {
                        service = phone;
                        inherit tag;
                        title = "Dishwasher";
                        message = "Start it before bed";
                        interruptionLevel = "time-sensitive";
                        data = startedButton;
                      })
                      { delay.minutes = nagIntervalMinutes; }
                    ];
                    until = [
                      (conditions.or [
                        (conditions.state {
                          entity_id = entities.dishwasher.needsRunning;
                          state = "off";
                        })
                        (conditions.template "{{ repeat.index >= ${toString nagLimit} }}")
                      ])
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
