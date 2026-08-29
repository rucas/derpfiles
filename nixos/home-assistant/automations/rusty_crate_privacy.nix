{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    conditions
    actions
    mkMultiTriggerAutomation
    ;
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "rusty_crate_privacy";
      alias = "Rusty Crate Camera Follows Crate Door";
      description = "Watch the crate while the door is shut; blank the camera once it is open.";

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
              sequence = [
                (actions.switchTurn {
                  entity_id = entities.rustyCrate.privacy;
                  state = "off";
                })
              ];
            }
            {
              conditions = [
                (conditions.state {
                  entity_id = entities.rustyCrate.door;
                  state = "on";
                })
              ];
              sequence = [
                (actions.switchTurn {
                  entity_id = entities.rustyCrate.privacy;
                  state = "on";
                })
              ];
            }
          ];
        }
      ];

      mode = "single";
    })
  ];
}
