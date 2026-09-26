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
  tag = "robovac-schedule";

  maxPressAgeSeconds = 10;

  firedBy = id: {
    condition = "trigger";
    inherit id;
  };

  armed = conditions.state {
    entity_id = entities.robovac.scheduled;
    state = "on";
  };

  # Reads the helper rather than hardcoding "6 AM", so editing the helper cannot
  # leave the notification claiming a time the automation no longer runs at.
  runTimeLabel = "{{ today_at(states('${entities.robovac.runTime}')).strftime('%-I:%M %p') }}";
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "robovac_schedule";
      alias = "Robovac Schedule";
      description = "Double-pressing the Dishwasher Button queues the Roborock's Vac than Vac + Mop routine for the next input_datetime.robovac_run_time.";
      # Queued, not parallel: nothing here waits, and a double press that lands
      # while the previous run is still writing the flag has to see the settled
      # state to toggle off the value it just toggled on.
      mode = "queued";
      triggers = [
        # Same Zigbee2MQTT topic dishwasher_reminder.nix subscribes to, split by
        # gesture: single press arms the dishwasher there, double press arms the
        # robovac here. Two subscriptions on one topic, so neither automation
        # has to know about the other's gesture.
        (
          triggers.mqtt {
            topic = entities.dishwasher.topic;
            value_template = "{{ value_json.action | default('') }}";
            payload = "double";
          }
          // {
            id = "button";
          }
        )
        (
          triggers.state {
            entity_id = entities.robovac.scheduled;
            to = "on";
          }
          // {
            id = "armed";
          }
        )
        (
          triggers.state {
            entity_id = entities.robovac.scheduled;
            to = "off";
          }
          // {
            id = "cleared";
          }
        )
        (triggers.time entities.robovac.runTime // { id = "run"; })
      ];
      action = [
        {
          choose = [
            # Toggle, unlike the dishwasher flag's turn_on: a second double
            # press before the run is the only way to call the robovac off
            # without reaching for the app.
            {
              conditions = [
                (firedBy "button")
                (conditions.freshMqttPress maxPressAgeSeconds)
              ];
              sequence = [
                {
                  action = "input_boolean.toggle";
                  target.entity_id = entities.robovac.scheduled;
                }
              ];
            }
            # Passive on both edges: confirms the gesture registered without a
            # banner or sound, which is what makes a blind double press on a
            # buttonless switch trustworthy.
            {
              conditions = [ (firedBy "armed") ];
              sequence = [
                (actions.notifyMobile {
                  service = phone;
                  inherit tag;
                  title = "Robovac";
                  message = "Vac than Vac + Mop scheduled for ${runTimeLabel}";
                  interruptionLevel = "passive";
                })
              ];
            }
            # Covers both ways the flag drops: a cancelling press, and the run
            # branch below consuming it.
            {
              conditions = [ (firedBy "cleared") ];
              sequence = [
                (actions.clearNotification {
                  service = phone;
                  inherit tag;
                })
              ];
            }
            # Clear before pressing, not after: a press that errors out (docked
            # elsewhere, no route to the cloud) should skip today rather than
            # leave the flag armed and surprise us with a vacuum tomorrow.
            {
              conditions = [
                (firedBy "run")
                armed
              ];
              sequence = [
                {
                  action = "input_boolean.turn_off";
                  target.entity_id = entities.robovac.scheduled;
                }
                {
                  action = "button.press";
                  target.entity_id = entities.robovac.vacThenMop;
                }
              ];
            }
          ];
        }
      ];
    })
  ];
}
