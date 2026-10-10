{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "master_bedroom_wakeup_sunrise";
      alias = "Master Bedroom Wake-Up Sunrise";
      description = ''
        Ramps the bedside lamps from an ember glow to daylight over the half
        hour before input_datetime.wakeup_time, so the room is bright by the
        time the alarm would otherwise go off.

        Gated on input_boolean.wakeup_alarm, which survives restarts, so arming
        it once is enough and a lie-in means switching it off. Turning either
        lamp off mid-ramp ends the sunrise.
      '';
      blueprint_path = "wake_up_light_sunrise.yaml";
      input = {
        light_entity = entities.masterBedroom.lamps;
        alarm_time_entity = entities.wakeupTime;
        enable_entity = entities.wakeupAlarm;
        sunrise_duration = 30;

        # 1% is the lowest these Hue bulbs take without snapping to full, and
        # the point of starting there is to be below the threshold that wakes
        # anyone — the first ten minutes should read as dawn, not as a lamp.
        start_brightness_pct = 1;
        end_brightness_pct = 100;

        # 2000 K is the warmest the bulbs go; 4000 K is cool enough to be
        # alerting at the end without overshooting into the blue-white that
        # makes a bedroom feel like an office.
        start_kelvin = 2000;
        end_kelvin = 4000;
      };
    })
  ];
}
