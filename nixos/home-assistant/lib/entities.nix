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
  };

  # UniFi Protect cameras, grouped per camera so the privacy helpers can take a
  # whole camera rather than four loose entity ids. Protect stashes the
  # pre-privacy mic level and record mode on the privacy switch
  # (prev_mic_level / prev_record_mode) and replays them when privacy lifts, but
  # the replay drops often enough that both have to be re-asserted by hand.
  # Entity ids are named after the camera model, not its Protect label.
  cameras = {
    rustyCrate = {
      privacy = "switch.rusty_crate_privacy_mode";
      microphone = "number.rusty_crate_microphone_level";
      recording = "select.g6_instant_recording_mode";
    };

    garage = {
      privacy = "switch.g4_instant_privacy_mode";
      microphone = "number.g4_instant_microphone_level";
      recording = "select.g4_instant_recording_mode";
      statusLight = "switch.g4_instant_status_light_on";
    };

    kitchen = {
      privacy = "switch.g5_flex_privacy_mode";
      microphone = "number.g5_flex_microphone_level";
      recording = "select.g5_flex_recording_mode";
      statusLight = "switch.g5_flex_status_light_on";
    };
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
