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
      id = "doorbell_chime_when_home";
      alias = "Doorbell Chime Only When Home";
      description = "Disable the doorbell when house is armed and no one is home. Enable when home.";

      triggers = [
        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = "armed_away";
          id = "armed";
        }

        {
          platform = "state";
          entity_id = entities.alarm.main;
          to = "disarmed";
          id = "disarmed";
        }
      ];

      action = [
        {
          choose = [
            {
              conditions = [ (conditions.template "{{ trigger.id == 'armed' }}") ];
              sequence = [
                (actions.service {
                  service = "select.select_option";
                  entity_id = entities.doorbell.chime;
                  data = {
                    option = "none";
                  };
                })
              ];
            }
            {
              conditions = [ (conditions.template "{{ trigger.id == 'disarmed' }}") ];
              sequence = [
                (actions.service {
                  service = "select.select_option";
                  entity_id = entities.doorbell.chime;
                  data = {
                    option = "mechanical";
                  };
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
