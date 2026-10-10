{ lib }:
rec {
  people = {
    lucas = {
      mobile = "mobile_app_lucas_iphone";
      person = "person.lucas_rondenet";
    };
    kelsey = {
      mobile = "mobile_app_kelsey_s_iphone";
      person = "person.kelsey_rondenet";
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

  # `vacThenMop` is a Roborock in-app routine surfaced as a button entity rather
  # than a `vacuum.start` call: the room order, fan speed and the vac-then-mop
  # pass order all live in the routine, so pressing it is the only way to
  # reproduce what the app does. The entity id is the routine name slugified, so
  # renaming the routine in the Roborock app renames the entity.
  robovac = {
    vacuum = "vacuum.roborock_qrevo_curv";
    vacThenMop = "button.roborock_qrevo_curv_vac_than_vac_mop";
    scheduled = "input_boolean.robovac_scheduled";
    runTime = "input_datetime.robovac_run_time";
  };

  # Aqara plug in line with the instant hot water recirculating pump. The pump
  # has no state of its own — the plug's switch *is* the pump — so the cycle can
  # flip it blind without reading anything back off the device.
  recircPump = {
    switch = "switch.hot_water_recirculating_pump";

    # Half-period of the 15-on/15-off schedule, not a countdown anything reads:
    # only the `timer.finished` event matters. Keeping the clock in a timer
    # rather than a `/15` time pattern is what lets a demand trigger restart it
    # mid-cycle and still hand the pump a full-length run.
    cycle = "timer.hot_water_recirc";

    # Washing dishes by hand wants a steady tap, not a loop that cuts the hot
    # water every other quarter hour. While this one runs the pump is held on
    # and the cycle timer is cancelled outright, so no flip can interrupt it.
    boost = "timer.hot_water_recirc_boost";

    # Stand-ins for "someone is about to want hot water". Master and guest only:
    # the front bathroom has leak sensors but no light in Home Assistant.
    demandLights = [
      "light.master_bathroom_main_lights"
      "light.master_bathroom_shower_lights"
      "light.master_bathroom_toilet"
      "light.guest_bathroom_main_lights"
    ];
  };

  # The closest thing the house has to a bed sensor. This presence sensor drops
  # to "off" once we settle for the night and reports "on" again when someone
  # actually moves, so the morning edge after a long gap means "up", not "in
  # bed" — see the guard in hot_water_recirc.nix.
  masterBedroom = {
    occupancy = "binary_sensor.master_bedroom_occupancy";

    # The bedside pair, as one unit. Both are Hue colour-temperature bulbs
    # (2000-6535 K) paired through Zigbee2MQTT rather than a Hue bridge, which
    # is why the wake-up sunrise can drive them with `color_temp_kelvin`.
    lamps = [
      "light.master_bedroom_lamp_left"
      "light.master_bedroom_lamp_right"
    ];
  };

  bedtime = "input_datetime.bedtime";

  wakeupTime = "input_datetime.wakeup_time";

  wakeupAlarm = "input_boolean.wakeup_alarm";

  vacationMode = "input_boolean.vacation_mode";

  allMobileDevices = lib.attrValues (lib.mapAttrs (_name: person: person.mobile) people);

  allPersons = lib.attrValues (lib.mapAttrs (_name: person: person.person) people);

  roomLights = room: lib.attrValues lights.${room} or [ ];

  allLights = lib.flatten (lib.mapAttrsToList (_: room: lib.attrValues room) lights);
}
