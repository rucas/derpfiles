{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "dishwasher_button";
      alias = "Dishwasher Button";
      description = "Aqara Wireless Mini Switch T1 by the dishwasher.";
      blueprint_path = "aqara_mini_switch_t1.yaml";
      input = {
        inherit (entities.dishwasher) topic;
        single_action = [
          {
            action = "input_boolean.toggle";
            target.entity_id = entities.dishwasher.needsRunning;
          }
        ];
      };
    })
  ];
}
