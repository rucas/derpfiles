{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities;
in
{
  # basnijholt/adaptive-lighting, the circadian layer: it nudges whatever is
  # already on along a colour-temperature and brightness curve tied to the real
  # sun, warm and dim at the edges of the day, bright and neutral in the middle.
  #
  # Chosen over the built-in `flux` integration for one reason that matters
  # here: flux rewrites every light that is on, every interval, with no notion
  # of another automation owning a light. It would overwrite the wake-up
  # sunrise ramp every 30 seconds. Adaptive Lighting has `take_over_control`
  # and `set_manual_control`, so wakeup_sunrise.nix can borrow the lamps for
  # its ramp and hand them back — see the pre/post sunrise actions there.
  #
  # Scoped to the bedside pair on purpose. Adaptive Lighting changes how a
  # light behaves every single time it comes on, so this starts where the
  # effect is wanted rather than house-wide.
  services.home-assistant.config.adaptive_lighting = [
    {
      name = "master_bedroom";
      lights = entities.masterBedroom.lamps;

      # The Hue white-and-colour-ambiance bulbs run 2000-6535 K. Capping the
      # top at 5000 K rather than their 6535 K ceiling keeps the midday end out
      # of the blue-white that reads as an office; the floor is the warmest
      # they go.
      min_color_temp = 2000;
      max_color_temp = 5000;

      min_brightness = 30;
      max_brightness = 100;

      # These are full-colour bulbs, so let the curve leave the white axis at
      # the ends of the day and reach the oranges a colour temperature alone
      # cannot express.
      prefer_rgb_color = true;

      # Sleep mode is the night state, asserted by bedtime rather than by the
      # sun: a deep amber at the brightness floor, dim enough to cross the room
      # by without resetting anyone's eyes.
      sleep_rgb_or_color_temp = "rgb_color";
      sleep_rgb_color = [
        255
        56
        0
      ];
      sleep_brightness = 1;

      # Hold the curve's own sunrise no earlier than 07:00. Without this the
      # adaptation starts at true dawn, which in midsummer is hours before
      # anyone is up and would have the lamps bright and neutral at 05:00 if
      # they came on at all.
      min_sunrise_time = "07:00:00";
      max_sunset_time = "21:30:00";

      # Back off the moment anything else sets brightness or colour, and never
      # resume on its own — only an explicit `set_manual_control: false` or the
      # light going off and on again hands control back. This is what keeps the
      # sunrise ramp and the Pico remotes from being fought.
      take_over_control = true;
      autoreset_control_seconds = 0;

      # Only adapt a light that was turned on without explicit brightness or
      # colour. A Pico press that asks for 3005 K at 100% means it, so the
      # curve should leave it alone.
      adapt_only_on_bare_turn_on = true;

      # Zigbee2MQTT applies brightness and colour in one message happily, so
      # the split-command workaround for fussier bulbs is not needed. 90s
      # interval with a 45s transition means the lamps drift rather than step.
      separate_turn_on_commands = false;
      interval = 90;
      transition = 45;

      # Off by default, and deliberately left off: it polls every light for
      # out-of-band changes, and with these bulbs on Zigbee2MQTT the state
      # round-trip is reliable enough that `take_over_control` alone catches
      # what matters.
      detect_non_ha_changes = false;
    }
  ];
}
