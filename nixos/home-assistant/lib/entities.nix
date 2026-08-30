{ lib }:
rec {
  people = {
    lucas = {
      mobile = "mobile_app_lucas_iphone";
      person = "person.lucas";
    };
    kelsey = {
      mobile = "mobile_app_kelsey_s_iphone";
      person = "person.kelsey";
    };
  };

  mediaPlayers = {
    living_room = {
      sonos_move = "media_player.sonos_move";
    };
  };

  lights = {
    living_room = {
      main = "light.living_room_main";
      accent = "light.living_room_accent";
    };
    bedroom = {
      main = "light.bedroom_main";
    };
  };

  switches = {
    bedroom = {
      fan = "switch.bedroom_fan";
    };
  };

  sensors = {
    temperature = {
      living_room = "sensor.living_room_temperature";
    };
  };

  alarm = {
    main = "alarm_control_panel.alarmo";
  };

  doorbell = {
    chime = "select.doorbell_chime";
  };

  rustyCrate = {
    door = "binary_sensor.rusty_crate_door_contact";
    privacy = "switch.rusty_crate_privacy_mode";
  };

  thermostat = {
    main = "climate.thermostat";

    # A group over the contact sensors, not the sensors themselves. The
    # Sensative strips only report on change, so one that has not moved since
    # the last restart sits at "unknown" — a group ignores such members instead
    # of stalling the way a condition over each raw state would.
    openings = "binary_sensor.climate_openings";

    # Snapshot of what the thermostat was doing before a door paused it. It
    # reports a null setpoint while off, so the setpoint has to be captured on
    # the way down; it cannot be read back afterwards.
    pausedByDoor = "input_boolean.thermostat_paused_by_door";
    restoreHvacMode = "input_select.thermostat_restore_hvac_mode";
    restoreTemperature = "input_number.thermostat_restore_temperature";
    restoreTempLow = "input_number.thermostat_restore_temp_low";
    restoreTempHigh = "input_number.thermostat_restore_temp_high";
  };

  openingSensors = {
    patioDoor = "binary_sensor.patio_door_window_door_is_open";
    diningWindowA = "binary_sensor.strips_guard_700_window_door_is_open_2";
    diningWindowB = "binary_sensor.strips_guard_700_window_door_is_open_4";
  };

  dishwasher = {
    needsRunning = "input_boolean.dishwasher_needs_running";
    topic = "zigbee2mqtt/Dishwasher Button";
  };

  bedtime = "input_datetime.bedtime";

  vacationMode = "input_boolean.vacation_mode";

  allMobileDevices = lib.attrValues (lib.mapAttrs (_name: person: person.mobile) people);

  roomLights = room: lib.attrValues lights.${room} or [ ];

  allLights = lib.flatten (lib.mapAttrsToList (_: room: lib.attrValues room) lights);
}
