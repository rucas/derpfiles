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
    };

    # `initial` re-applies on every restart rather than restoring the previous
    # value. That is the point here: Nix owns the time, so a UI edit survives
    # only until the next restart. Wall-clock, interpreted in the host time
    # zone (`time.timeZone`), so it follows the PST/PDT shift on its own.
    # dishwasher_reminder.nix triggers on this entity instead of a literal,
    # which keeps this the single source of truth for the nag time.
    input_datetime.bedtime = {
      name = "Bedtime";
      icon = "mdi:bed-clock";
      has_date = false;
      has_time = true;
      initial = "21:00:00";
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
