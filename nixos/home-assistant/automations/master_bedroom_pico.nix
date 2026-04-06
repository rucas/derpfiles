{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) mkBlueprintAutomation;

  mkPicoAutomation =
    { name, pico_id }:
    mkBlueprintAutomation {
      id = "master_bedroom_pico_${lib.toLower name}";
      alias = "Master Bedroom Pico ${name}";
      blueprint_path = "lutron_pico_5_button_actions.yaml";
      input = {
        inherit pico_id;
        short_click_action_on = [
          {
            action = "light.turn_on";
            metadata = { };
            target.entity_id = [
              "light.master_bedroom_lamp_left"
              "light.master_bedroom_lamp_right"
            ];
            data = {
              transition = 3;
              color_temp_kelvin = 3005;
              brightness_pct = 100;
            };
          }
        ];
        short_click_action_off = [
          {
            action = "light.turn_off";
            metadata = { };
            data.transition = 3;
            target.area_id = [ "master_bedroom" ];
          }
        ];
        double_click_action_off = [
          {
            action = "light.turn_off";
            metadata = { };
            data.transition = 3;
            target.area_id = [
              "master_bedroom"
              "master_bathroom"
            ];
          }
        ];
        short_click_action_up = [
          {
            action = "light.turn_on";
            target.device_id = [
              "52c8623cb007dd8cebf4ab4f58df6f62"
              "3821039564adbbd9b098e0977066b6a8"
            ];
            data.brightness_step_pct = 10;
          }
        ];
        short_click_action_down = [
          {
            action = "light.turn_on";
            target.device_id = [
              "52c8623cb007dd8cebf4ab4f58df6f62"
              "3821039564adbbd9b098e0977066b6a8"
            ];
            data.brightness_step_pct = -10;
          }
        ];
      };
    };
in
{
  services.home-assistant.config."automation manual" = [
    (mkPicoAutomation {
      name = "A";
      pico_id = "ac4c0d4c33c32d9f3d0323e7d0b7a953";
    })
    (mkPicoAutomation {
      name = "B";
      pico_id = "28416cdafc91efc5b755ac0b414d5362";
    })
    (mkPicoAutomation {
      name = "C";
      pico_id = "0c3c19f854df4723c2bca68ee69dffdd";
    })
  ];
}
