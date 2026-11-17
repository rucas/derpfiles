{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;

  inherit (entities.masterBedroom) lamps;

  setLamps = data: [
    {
      action = "light.turn_on";
      target.entity_id = lamps;
      inherit data;
    }
  ];

  bothRoomsOff = [
    {
      action = "light.turn_off";
      data.transition = 3;
      target.area_id = [
        "master_bedroom"
        "master_bathroom"
      ];
    }
  ];
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "master_bedroom_pico";
      alias = "Master Bedroom Pico";
      blueprint_path = "lutron_pico_5_button_actions_multi.yaml";
      input = {
        # Registry uuids, and the documented exception to entity-ids-only: the
        # Caséta integration never puts a Pico press on the state machine, so
        # the blueprint has to match the remote by device. Re-pairing one mints
        # a new uuid and that remote stops firing silently.
        pico_a = "ac4c0d4c33c32d9f3d0323e7d0b7a953";
        pico_b = "28416cdafc91efc5b755ac0b414d5362";
        pico_c = "0c3c19f854df4723c2bca68ee69dffdd";

        short_click_action_on = setLamps {
          brightness_pct = 100;
          color_temp_kelvin = 3005;
          transition = 3;
        };

        # The Lutron "favourite" button holds the night bathroom trip: enough
        # light to walk by without resetting anyone's eyes. A double tap on Off
        # is the way back — it covers both rooms, where a single tap leaves the
        # bathroom lit.
        #
        # The bathroom sits at half the bedroom's level: it is the room you end
        # up standing in, and its three dimmers light a smaller space between
        # them. 2200 K is the warmest the bedside bulbs go; the bathroom dimmers
        # report `brightness` and nothing else, so brightness is the whole
        # scene there.
        short_click_action_stop =
          setLamps {
            brightness_pct = 20;
            color_temp_kelvin = 2200;
            transition = 3;
          }
          ++ [
            {
              action = "light.turn_on";
              target.entity_id = entities.masterBathroom.lights;
              data = {
                brightness_pct = 10;
                transition = 3;
              };
            }
          ];

        # One step per press, and deliberately no transition. The blueprint runs
        # `mode: single` and holds a run open for up to delay_hold +
        # delay_click (~1.25s) classifying the press, so a hold-to-dim loop
        # would spend its time being dropped as "Already running"; a fade still
        # in flight eats the next press for the same reason. Adaptive Lighting
        # owns these two bulbs (adaptive_lighting.nix) but a step carries an
        # explicit brightness, so `take_over_control` hands the lamps over on
        # the first press instead of fighting the arrows.
        short_click_action_up = setLamps { brightness_step_pct = 10; };
        short_click_action_down = setLamps { brightness_step_pct = -10; };

        short_click_action_off = [
          {
            action = "light.turn_off";
            data.transition = 3;
            target.area_id = [ "master_bedroom" ];
          }
        ];
        # Both rooms, on either gesture. A hold is the one you can find in the
        # dark; the double tap stays because it is what the remote has always
        # done. The blueprint classifies a hold by waiting out delay_hold (1s)
        # on the release, so the lights go off a second after the press rather
        # than on it — holding longer changes nothing.
        long_click_action_off = bothRoomsOff;
        double_click_action_off = bothRoomsOff;
      };
    })
  ];
}
