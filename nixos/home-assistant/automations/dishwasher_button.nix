{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) actions mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "dishwasher_button";
      alias = "Dishwasher Button";
      description = "Aqara Wireless Mini Switch T1 by the dishwasher.";
      blueprint_path = "aqara_mini_switch_t1.yaml";
      input = {
        topic = "zigbee2mqtt/Dishwasher Button";
        single_action = [
          (actions.notifyAllMobile {
            title = "Dishwasher";
            message = "Dishwasher button pressed";
          })
        ];
      };
    })
  ];
}
