{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;

  inherit (entities.downstairs) lamps;

  # Every button but Off is a `light.turn_on` against the same three lamps, so
  # the only thing that varies is the data payload.
  #
  # One action for all three is safe even though only the living room lamp can
  # take `color_temp_kelvin`: the light component filters each parameter against
  # the target's own `supported_color_modes`, so the two Caséta dimmers drop the
  # colour and keep the brightness. Verified against the hardware rather than
  # assumed — a `color_temp_kelvin` call on `light.dining_room_table_lamp`
  # leaves it at `color_mode: brightness` with its brightness untouched and logs
  # nothing at all.
  setLamps = data: [
    {
      action = "light.turn_on";
      target.entity_id = lamps;
      inherit data;
    }
  ];
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "downstairs_lamps_pico_remote";
      alias = "Downstairs Lamp Pico Remote";
      blueprint_path = "lutron_pico_5_button_actions.yaml";
      input = {
        # A registry uuid, and the documented exception to entity-ids-only: the
        # Caséta integration gives a Pico nothing to trigger on as an entity.
        # It registers `button.living_room_pico_*` rows, but they never reach
        # the state machine, so there is no `event.received` to use and the
        # blueprint has to match the remote by device. Re-pairing this Pico
        # mints a new uuid and the automation stops firing silently.
        pico_id = "a1a16f601278b1870f841ca03a5e0c76";

        # On means "light the room", not "restore whatever level was left
        # behind". Without an explicit brightness, a press after the arrows had
        # taken the lamps down to 10% turns them on at 10% and reads as the
        # button having done nothing.
        short_click_action_on = setLamps {
          brightness_pct = 100;
          color_temp_kelvin = 2700;
          transition = 3;
        };

        # The middle button is the Lutron "favourite", so it holds the evening
        # scene: low and deep-warm, the state you actually want the downstairs
        # lamps in after dark. Deliberately warmer than On's 2700 K — this is
        # ambience, not light to read by.
        short_click_action_stop = setLamps {
          brightness_pct = 40;
          color_temp_kelvin = 2200;
          transition = 3;
        };

        # One step per press rather than a hold-to-dim loop. The blueprint runs
        # `mode: single` and holds a run open for up to delay_hold +
        # delay_click (~1.25s) while it classifies the press, so a repeat loop
        # would spend most of its time being dropped as "Already running".
        # Stepping per press is the behaviour that survives that, which is also
        # why these carry no transition: a fade still in flight eats the next
        # press.
        short_click_action_up = setLamps { brightness_step_pct = 10; };
        short_click_action_down = setLamps { brightness_step_pct = -10; };

        # Matches On's fade so the room does not snap to black.
        short_click_action_off = [
          {
            action = "light.turn_off";
            target.entity_id = lamps;
            data.transition = 3;
          }
        ];
      };
    })
  ];
}
