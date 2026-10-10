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
        Ramps the bedside lamps through a dawn — red, orange, amber, then up
        the white axis to daylight — over the hour before
        input_datetime.wakeup_time, so the room is bright by the time the alarm
        would otherwise go off.

        Fires once an hour before that time rather than polling, so the
        automation's stored traces hold real sunrises instead of no-op minute
        ticks. The flip side is that a restart between 05:30 and 06:30 ends
        that morning's ramp.

        Gated on input_boolean.wakeup_alarm, which survives restarts, so arming
        it once is enough and a lie-in means switching it off. Turning either
        lamp off mid-ramp ends the sunrise.

        Takes the lamps off Adaptive Lighting before the first step and keeps
        them, because Adaptive Lighting's curve is still at its warm floor at
        06:30 and releasing them there would drag the finished sunrise back to
        amber. They return to the circadian curve the next time they are
        switched off and on.
      '';
      blueprint_path = "wake_up_light_sunrise.yaml";
      input = {
        light_entity = entities.masterBedroom.lamps;
        alarm_time_entity = entities.wakeupTime;
        enable_entity = entities.wakeupAlarm;
        # Doubles as the trigger offset and the ramp length: the automation
        # fires at wakeup_time minus this, then spends exactly this long
        # getting there. One value, so the start and the ramp cannot disagree.
        sunrise_offset = "-01:00:00";

        # 1% is the lowest these Hue bulbs take without snapping to full, and
        # the point of starting there is to be below the threshold that wakes
        # anyone — the first ten minutes should read as dawn, not as a lamp.
        start_brightness_pct = 1;
        end_brightness_pct = 100;

        # The red-through-amber gradient and its handover temperature are left
        # at the blueprint's defaults on purpose. The two have to agree — the
        # last RGB stop is what Home Assistant renders `start_kelvin` as, which
        # is what makes the switch from RGB to colour temperature invisible —
        # and splitting a coupled pair across two files is how it ends up
        # mismatched. They live together in the blueprint's `colour_stops` and
        # `start_kelvin`, which also spares nixfmt exploding a gradient into
        # one integer per line.

        # Two thirds of the ramp in reds and oranges, the last third climbing
        # the white axis. Pushed much higher and the room never actually gets
        # bright enough to wake anyone; much lower and the red is over before
        # it registers.
        colour_phase_fraction = 0.65;

        # 4000 K is cool enough to be alerting at the end without overshooting
        # into the blue-white that makes a bedroom feel like an office. The
        # yellow stage of the sunrise happens on the way, around 2700-3200 K.
        end_kelvin = 4000;

        # Claim the lamps before the first step. Adaptive Lighting's
        # `take_over_control` would notice the ramp's own brightness changes
        # and stand down on its own, but saying so up front means the handover
        # does not depend on it winning that race every morning.
        pre_sunrise_actions = [
          {
            action = "adaptive_lighting.set_manual_control";
            data = {
              entity_id = entities.adaptiveLighting.masterBedroom;
              lights = entities.masterBedroom.lamps;
              manual_control = true;
            };
          }
        ];

        # Deliberately no post_sunrise_actions handing control back. Adaptive
        # Lighting's curve is at its warm floor this early: its
        # `color_temp_kelvin` returns `min_color_temp` for every sun position at
        # or below the horizon, and 06:30 is before its virtual sunrise all year
        # (actual sunrise here is never earlier than the 07:00 `min_sunrise_time`
        # floor). Releasing at the alarm time therefore had Adaptive Lighting
        # target 83% / 2000 K within one 90s interval, dragging the lamps from
        # the neutral white the ramp just reached back to deep amber and undoing
        # the alerting end of the sunrise.
        #
        # So the ramp keeps the lamps. Nothing is stranded: switch.py's
        # state_changed listener resets manual control on any on -> off
        # transition, so Adaptive Lighting picks them up again by itself the next
        # time they are switched off and back on — in the evening, when its curve
        # is somewhere useful.
      };
    })
  ];
}
