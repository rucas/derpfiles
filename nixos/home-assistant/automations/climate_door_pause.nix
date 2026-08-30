{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    conditions
    actions
    mkAutomation
    mkMultiTriggerAutomation
    ;

  inherit (entities) thermostat;

  isRunning = {
    condition = "not";
    conditions = [
      (conditions.state {
        entity_id = thermostat.main;
        state = "off";
      })
    ];
  };

  isReporting = {
    condition = "not";
    conditions = [
      {
        condition = "state";
        entity_id = thermostat.main;
        state = [
          "unavailable"
          "unknown"
        ];
      }
    ];
  };

  # The setpoint attributes read null in whichever modes do not use them —
  # `temperature` is null under heat_cool, the low/high pair is null under
  # heat and cool. The fallback keeps input_number.set_value inside its 45-95
  # range on those writes; the resume branch only reads back the pair that
  # matches the stored mode, so the unused value is never applied.
  snapshot =
    {
      helper,
      attribute,
      fallback,
    }:
    actions.service {
      service = "input_number.set_value";
      entity_id = helper;
      data.value = "{{ state_attr('${thermostat.main}', '${attribute}') | float(${toString fallback}) }}";
    };

  setHvacMode = mode: {
    service = "climate.set_hvac_mode";
    entity_id = thermostat.main;
    data.hvac_mode = mode;
  };

  restoreSetpoint =
    { mode, data }:
    {
      conditions = [
        (conditions.state {
          entity_id = thermostat.restoreHvacMode;
          state = mode;
        })
      ];
      sequence = [
        {
          service = "climate.set_temperature";
          entity_id = thermostat.main;
          inherit data;
        }
      ];
    };

  storedSetpoint = helper: "{{ states('${helper}') | float }}";

  forgetSnapshot = [
    (actions.service {
      service = "input_boolean.turn_off";
      entity_id = thermostat.pausedByDoor;
    })
    (actions.service {
      service = "input_select.select_option";
      entity_id = thermostat.restoreHvacMode;
      data.option = "off";
    })
  ];
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "climate_door_pause";
      alias = "Door/Window Open Pauses Thermostat";
      description = "Shut the thermostat off after 3 minutes of an opening, and put it back the way it was once everything is closed.";

      triggers = [
        {
          platform = "state";
          entity_id = thermostat.openings;
          to = "on";
          for = "00:03:00";
        }

        # Shorter than the pause delay on purpose: a door cycled twice in quick
        # succession should settle rather than short-cycle the compressor, but
        # waiting three minutes to give the heat back is just a cold house.
        {
          platform = "state";
          entity_id = thermostat.openings;
          to = "off";
          for = "00:00:30";
        }

        {
          platform = "homeassistant";
          event = "start";
        }
      ];

      # Branch on where things currently stand rather than which trigger fired,
      # so the startup trigger reconciles a restart that happened mid-pause.
      # Neither branch matches while a door is open and the thermostat is
      # already off, which is the state a restart normally finds.
      action = [
        {
          choose = [
            {
              conditions = [
                (conditions.state {
                  entity_id = thermostat.openings;
                  state = "on";
                })
                isRunning
              ];
              sequence = [
                (actions.service {
                  service = "input_select.select_option";
                  entity_id = thermostat.restoreHvacMode;
                  data.option = "{{ states('${thermostat.main}') }}";
                })
                (snapshot {
                  helper = thermostat.restoreTemperature;
                  attribute = "temperature";
                  fallback = 68;
                })
                (snapshot {
                  helper = thermostat.restoreTempLow;
                  attribute = "target_temp_low";
                  fallback = 68;
                })
                (snapshot {
                  helper = thermostat.restoreTempHigh;
                  attribute = "target_temp_high";
                  fallback = 74;
                })
                (actions.service {
                  service = "input_boolean.turn_on";
                  entity_id = thermostat.pausedByDoor;
                })
                (setHvacMode "off")
              ];
            }

            {
              conditions = [
                (conditions.state {
                  entity_id = thermostat.openings;
                  state = "off";
                })
                (conditions.state {
                  entity_id = thermostat.pausedByDoor;
                  state = "on";
                })
              ];
              sequence = [
                # Mode first: the thermostat rejects a setpoint while it is off,
                # and the HomeKit bridge needs a moment to accept the new mode
                # before the setpoint lands.
                (setHvacMode "{{ states('${thermostat.restoreHvacMode}') }}")
                (actions.delay 2)
                {
                  choose = [
                    (restoreSetpoint {
                      mode = "heat_cool";
                      data = {
                        target_temp_low = storedSetpoint thermostat.restoreTempLow;
                        target_temp_high = storedSetpoint thermostat.restoreTempHigh;
                      };
                    })
                    (restoreSetpoint {
                      mode = "heat";
                      data.temperature = storedSetpoint thermostat.restoreTemperature;
                    })
                    (restoreSetpoint {
                      mode = "cool";
                      data.temperature = storedSetpoint thermostat.restoreTemperature;
                    })
                  ];
                }
              ]
              ++ forgetSnapshot;
            }
          ];
        }
      ];

      mode = "single";
    })

    # Without this, turning the heat back on by hand with the door still open
    # leaves the snapshot owed, and closing the door hours later overwrites
    # that deliberate choice with a stale one.
    (mkAutomation {
      id = "climate_door_pause_manual_override";
      alias = "Manual Thermostat Change Cancels Door Pause";
      description = "Drop the pending restore once the thermostat is turned back on by hand.";

      trigger = [
        {
          platform = "state";
          entity_id = thermostat.main;
          from = "off";
        }
      ];

      # The openings check is what separates a person from this automation's own
      # resume branch, which only ever runs once everything is closed.
      condition = [
        (conditions.state {
          entity_id = thermostat.pausedByDoor;
          state = "on";
        })
        (conditions.state {
          entity_id = thermostat.openings;
          state = "on";
        })
        isReporting
      ];

      action = forgetSnapshot;

      mode = "single";
    })
  ];
}
