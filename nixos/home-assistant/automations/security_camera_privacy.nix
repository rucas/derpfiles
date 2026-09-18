{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    conditions
    actions
    mkMultiTriggerAutomation
    ;

  armedStates = [
    "armed_home"
    "armed_away"
  ];

  cameras = [
    entities.cameras.garage
    entities.cameras.kitchen
  ];
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "security_camera_privacy";
      alias = "Security Cameras Follow The Alarm";
      description = "Blank the indoor cameras while the alarm is disarmed; put them back to recording once it is armed. Leaving privacy re-asserts the mic level and record mode Protect is supposed to restore.";

      triggers = [
        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = "disarmed";
        }

        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = armedStates;
        }

        {
          platform = "homeassistant";
          event = "start";
        }
      ];

      action = [
        {
          choose = [
            {
              conditions = [
                (conditions.state {
                  entity_id = entities.alarm.main;
                  state = "disarmed";
                })
              ];
              sequence = lib.concatMap actions.cameraPrivacyOn cameras;
            }
            {
              conditions = [
                (conditions.state {
                  entity_id = entities.alarm.main;
                  state = armedStates;
                })
              ];
              sequence = lib.concatMap actions.cameraPrivacyOff cameras;
            }
          ];
        }
      ];

      # The restore path sleeps, so arming during a disarm run has to preempt it
      # rather than be dropped — the latest alarm state wins.
      mode = "restart";
    })
  ];
}
