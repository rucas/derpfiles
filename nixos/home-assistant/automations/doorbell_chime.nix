{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    conditions
    actions
    mkMultiTriggerAutomation
    ;

  mkChimeBranch =
    { alarmState, option }:
    {
      conditions = [
        (conditions.state {
          entity_id = entities.alarm.main;
          state = alarmState;
        })
      ];
      sequence = [
        (actions.service {
          service = "select.select_option";
          entity_id = entities.doorbell.chime;
          data = {
            inherit option;
          };
        })
      ];
    };
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "doorbell_chime_when_home";
      alias = "Doorbell Chime Only When Home";
      description = "Disable the doorbell when house is armed and no one is home. Enable when home.";

      triggers = [
        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = "armed_away";
        }

        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = "disarmed";
        }

        {
          platform = "homeassistant";
          event = "start";
        }
      ];

      # Branch on the alarm's current state rather than which trigger fired, so
      # the startup trigger reconciles the chime after a restart. Any other
      # armed_* state matches neither branch and leaves the chime untouched.
      action = [
        {
          choose = [
            (mkChimeBranch {
              alarmState = "armed_away";
              option = "none";
            })
            (mkChimeBranch {
              alarmState = "disarmed";
              option = "mechanical";
            })
          ];
        }
      ];

      mode = "single";
    })
  ];
}
