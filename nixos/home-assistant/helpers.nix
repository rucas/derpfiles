{ lib, ... }:
let
  haLib = import ./lib { inherit lib; };
  inherit (haLib) entities;

  setpoint = name: {
    inherit name;
    icon = "mdi:thermometer";
    min = 45;
    max = 95;
    step = 1;
    mode = "box";
    unit_of_measurement = "°F";
  };
in
{
  services.home-assistant.config = {
    input_boolean = {
      dishwasher_needs_running = {
        name = "Dishwasher Needs Running";
        icon = "mdi:dishwasher";
      };

      # Suppresses automations that only make sense with someone in the house.
      # Automations opt in by testing for "off" rather than the toggle switching
      # anything off itself, so flipping it never leaves a device stranded.
      vacation_mode = {
        name = "Vacation Mode";
        icon = "mdi:bag-suitcase";
      };

      # Deliberately no `initial` here or on the restore helpers below, unlike
      # bedtime: they restore across a restart. A restart while a door is open
      # is exactly when the snapshot has to survive, or the thermostat never
      # comes back.
      thermostat_paused_by_door = {
        name = "Thermostat Paused By Door";
        icon = "mdi:hvac-off";
      };

      # Armed by a double press on the Dishwasher Button, consumed by
      # robovac_schedule.nix at input_datetime.robovac_run_time. No `initial`,
      # for the same reason as the restore helpers above: the press lands the
      # evening before the run, so the flag has to survive a restart in between.
      robovac_scheduled = {
        name = "Robovac Scheduled";
        icon = "mdi:robot-vacuum";
      };

      # Gate for wakeup_sunrise.nix. Deliberately no `initial`, unlike bedtime
      # and for the same reason as the restore helpers above: an alarm has to
      # survive a restart. A nightly core update that reset this to off would
      # mean a morning with no sunrise and no indication why.
      wakeup_alarm = {
        name = "Wake-Up Alarm";
        icon = "mdi:alarm";
      };
    };

    # `initial` re-applies on every restart rather than restoring the previous
    # value. That is the point here: Nix owns these times, so a UI edit survives
    # only until the next restart. Wall-clock, interpreted in the host time zone
    # (`time.timeZone`), so they follow the PST/PDT shift on their own. The
    # automations trigger on these entities instead of literals, which keeps
    # each one the single source of truth for its schedule.
    input_datetime = {
      bedtime = {
        name = "Bedtime";
        icon = "mdi:bed-clock";
        has_date = false;
        has_time = true;
        initial = "21:00:00";
      };

      robovac_run_time = {
        name = "Robovac Run Time";
        icon = "mdi:clock-time-six-outline";
        has_date = false;
        has_time = true;
        initial = "06:00:00";
      };

      # The moment the bedside lamps reach full brightness, not the moment the
      # sunrise starts — the blueprint backs the ramp off this time by its
      # configured duration.
      wakeup_time = {
        name = "Wake-Up Time";
        icon = "mdi:weather-sunset-up";
        has_date = false;
        has_time = true;
        initial = "06:30:00";
      };
    };

    # The pump's whole schedule, held as one half-period: every expiry flips the
    # switch, so a single 15-minute timer yields 15 on, 15 off. `restore` is
    # what keeps a cycle alive across a restart — without it the timer comes
    # back idle and the pump would sit untouched until the next 5 AM start.
    timer.hot_water_recirc = {
      name = "Hot Water Recirc Cycle";
      icon = "mdi:pump";
      duration = "00:15:00";
      restore = true;
    };

    # A triple press on the Dishwasher Button holds the pump on for one of
    # these instead of cycling it. The automation reads this `duration` back
    # when it names the end time in its confirmation, so the value here is the
    # only place the boost length is written down.
    timer.hot_water_recirc_boost = {
      name = "Hot Water Recirc Boost";
      icon = "mdi:silverware-clean";
      duration = "00:30:00";
      restore = true;
    };

    # One entity standing for "some opening is letting conditioned air out".
    # A group is on when any member is on and skips members reporting unknown,
    # which is the normal resting state for a Sensative strip that has not
    # changed since the last restart.
    binary_sensor = [
      {
        platform = "group";
        name = "Climate Openings";
        unique_id = "climate_openings";
        device_class = "opening";
        entities = lib.attrValues entities.openingSensors;
      }
    ];

    # "off" leads so it is what a first-ever start selects — same value the
    # resume branch writes back to mean "nothing owed".
    input_select.thermostat_restore_hvac_mode = {
      name = "Thermostat Restore HVAC Mode";
      icon = "mdi:hvac";
      options = [
        "off"
        "heat"
        "cool"
        "heat_cool"
      ];
    };

    input_number = {
      thermostat_restore_temperature = setpoint "Thermostat Restore Temperature";
      thermostat_restore_temp_low = setpoint "Thermostat Restore Temp Low";
      thermostat_restore_temp_high = setpoint "Thermostat Restore Temp High";
    };
  };
}
