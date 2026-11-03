{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "nursery_lamp_pico";
      alias = "Nursery Lamp Pico";
      blueprint_path = "lutron_pico_5_button_actions_multi.yaml";
      input = {
        # Lutron still names these "Guest Bedroom Dresser Lamp Remote" and
        # "Guest Bedroom Lamp Remote".
        pico_a = "44b3ffafc340bb1e7daa9aaaeaef8850";
        pico_b = "56f2ace2ef0fc233cfea4a0ee1898069";
        short_click_action_on = [
          {
            action = "light.turn_on";
            target.entity_id = entities.nursery.lamp;
            data.transition = 3;
          }
        ];
        short_click_action_off = [
          {
            action = "light.turn_off";
            target.entity_id = entities.nursery.lamp;
            data.transition = 3;
          }
        ];
        short_click_action_up = [
          {
            action = "light.turn_on";
            target.entity_id = entities.nursery.lamp;
            data.brightness_step_pct = 10;
          }
        ];
        short_click_action_down = [
          {
            action = "light.turn_on";
            target.entity_id = entities.nursery.lamp;
            data.brightness_step_pct = -10;
          }
        ];
      };
    })
  ];
}
