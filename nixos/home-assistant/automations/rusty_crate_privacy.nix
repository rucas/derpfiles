{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    conditions
    actions
    mkMultiTriggerAutomation
    ;

  camera = entities.cameras.rustyCrate;
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "rusty_crate_privacy";
      alias = "Rusty Crate Camera Follows Crate Door";
      description = "Watch the crate while the door is shut; blank the camera once it is open. Leaving privacy re-asserts the mic level and record mode Protect is supposed to restore.";

      triggers = [
        {
          platform = "state";
          entity_id = entities.rustyCrate.door;
          to = "off";
        }

        {
          platform = "state";
          entity_id = entities.rustyCrate.door;
          to = "on";
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
                  entity_id = entities.rustyCrate.door;
                  state = "off";
                })
              ];
              sequence = actions.cameraPrivacyOff camera;
            }
            {
              conditions = [
                (conditions.state {
                  entity_id = entities.rustyCrate.door;
                  state = "on";
                })
              ];
              sequence = actions.cameraPrivacyOn camera;
            }
          ];
        }
      ];

      # The restore path sleeps, so a door toggled during it has to preempt the
      # run in flight rather than be dropped — the latest door state wins.
      mode = "restart";
    })
  ];
}
