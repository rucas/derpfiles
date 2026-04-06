{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "downstairs_lamps_pico_remote";
      alias = "Downstairs Lamp Pico Remote";
      blueprint_path = "lutron_pico_5_button_actions.yaml";
      input = {
        pico_id = "a1a16f601278b1870f841ca03a5e0c76";
        short_click_action_on = [
          {
            action = "light.turn_on";
            metadata = { };
            data.transition = 3;
            target.device_id = [
              "2027964aae0251ca6a9f9b07e2673c18"
              "35ac2a24f74747b0a3046b41983d2a9b"
              "328e0a3cf64e9a50912dedaaf3ed9e10"
            ];
          }
        ];
        short_click_action_off = [
          {
            action = "light.turn_off";
            metadata = { };
            data = { };
            target.device_id = [
              "2027964aae0251ca6a9f9b07e2673c18"
              "35ac2a24f74747b0a3046b41983d2a9b"
              "328e0a3cf64e9a50912dedaaf3ed9e10"
            ];
          }
        ];
      };
    })
  ];
}
