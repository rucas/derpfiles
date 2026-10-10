{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    actions
    conditions
    triggers
    mkMultiTriggerAutomation
    ;

  inherit (entities) recircPump;

  windowStart = "05:00:00";
  windowEnd = "23:00:00";

  # Long enough that going to bed, or passing through the bedroom during the
  # day, cannot pass for a night's sleep. The sensor reliably drops to "off"
  # within an hour of settling, so anything shorter than this is just movement.
  sleepGapSeconds = 3600;

  # Same guard the other two gestures on this button use: Zigbee2MQTT retains
  # the last payload, so without it a restart replays the press.
  maxPressAgeSeconds = 10;

  phone = entities.people.lucas.mobile;
  boostTag = "recirc-boost";

  firedBy = id: {
    condition = "trigger";
    inherit id;
  };

  # Re-tested on every flip rather than trusted from the 5 AM start, so a cycle
  # still in progress at 23:00 stops there instead of running on.
  inWindow = conditions.time {
    after = windowStart;
    before = windowEnd;
  };

  # Alarmo rather than the `person` entities, which cannot carry this: a device
  # tracker that stops reporting sits at "home" forever, and an OR across the
  # household then never goes false — kelsey's has read "home" unchanged since
  # 1 Oct 2026, straight through arm-away windows with the house empty. Arming
  # away is a deliberate act, so it is the one signal here that cannot quietly
  # decay into "somebody might be home".
  #
  # Only armed_away counts as out. armed_home is the nightly bedtime arm and the
  # pump keeps cycling through it until 23:00.
  notArmedAway = {
    condition = "not";
    conditions = [
      (conditions.state {
        entity_id = entities.alarm.main;
        state = "armed_away";
      })
    ];
  };

  notOnVacation = conditions.state {
    entity_id = entities.vacationMode;
    state = "off";
  };

  shouldCycle = [
    inWindow
    notArmedAway
    notOnVacation
  ];

  boosting = conditions.state {
    entity_id = recircPump.boost;
    state = "active";
  };

  runCycle = [
    (actions.switchTurn {
      entity_id = recircPump.switch;
      state = "on";
    })
    (actions.timerStart recircPump.cycle)
  ];

  # Clearing the banner here rather than only where a boost ends cleanly covers
  # the stops too, so arming away mid-wash does not leave a notification
  # claiming the pump is running. Clearing a tag that was never shown is a
  # no-op, which is what makes it safe to fold in unconditionally.
  stopCycle = [
    (actions.switchTurn {
      entity_id = recircPump.switch;
      state = "off";
    })
    (actions.timerCancel recircPump.cycle)
    (actions.timerCancel recircPump.boost)
    (actions.clearNotification {
      service = phone;
      tag = boostTag;
    })
  ];

  # Reads the timer's own duration instead of repeating 30 minutes here, so the
  # end time cannot drift from the timer that actually governs the boost.
  boostEndsAt = "{{ (now() + (state_attr('${recircPump.boost}', 'duration') | as_timedelta)).strftime('%-I:%M %p') }}";

  startBoost = [
    (actions.switchTurn {
      entity_id = recircPump.switch;
      state = "on";
    })
    # Cancelled, not left running: a flip landing mid-wash would drop the hot
    # water for fifteen minutes. The boost's own expiry re-arms the cycle.
    (actions.timerCancel recircPump.cycle)
    (actions.timerStart recircPump.boost)
    (actions.notifyMobile {
      service = phone;
      tag = boostTag;
      title = "Hot Water";
      message = "Recirculating pump holding on until ${boostEndsAt}";
      interruptionLevel = "passive";
    })
  ];
in
{
  services.home-assistant.config."automation manual" = [
    (mkMultiTriggerAutomation {
      id = "hot_water_recirc";
      alias = "Hot Water Recirculating Pump";
      description = "Cycle the recirculating pump 15 minutes on, 15 off between 5 AM and 11 PM unless the alarm is armed away, and give it a full run on demand when a bathroom light comes on, when we get home, or when we get out of bed. A triple press on the Dishwasher Button holds it on for 30 minutes to wash up.";

      # Nothing here waits, so the branches settle in microseconds — but a flip
      # and a demand landing in the same instant have contradictory outcomes,
      # and queueing them means the later one wins rather than being dropped the
      # way `single` would drop it.
      mode = "queued";

      triggers = [
        (
          triggers.event {
            event_type = "timer.finished";
            event_data.entity_id = recircPump.cycle;
          }
          // {
            id = "flip";
          }
        )

        (triggers.time windowStart // { id = "open"; })
        (triggers.time windowEnd // { id = "stop"; })

        # Arming away stops the pump on the spot. Without this the cycle would
        # keep running until the next flip noticed the house was empty, leaving
        # the pump on for up to 15 minutes after we walk out.
        (
          triggers.state {
            entity_id = entities.alarm.main;
            to = "armed_away";
          }
          // {
            id = "stop";
          }
        )

        (
          triggers.state {
            entity_id = recircPump.demandLights;
            to = "on";
          }
          // {
            id = "demand";
          }
        )

        # Disarming out of away is the reliable "we got home" — it covers whoever
        # actually walks in, where the zone trigger below only covers a phone
        # still reporting its location. Both are kept: the geofence usually
        # crosses first, which buys the pump a head start on the driveway.
        (
          triggers.state {
            entity_id = entities.alarm.main;
            from = "armed_away";
            to = "disarmed";
          }
          // {
            id = "demand";
          }
        )

        (
          triggers.zone {
            entity_id = entities.allPersons;
            zone = "zone.home";
            event = "enter";
          }
          // {
            id = "demand";
          }
        )

        (
          triggers.state {
            entity_id = entities.masterBedroom.occupancy;
            to = "on";
          }
          // {
            id = "woke";
          }
        )

        # Third gesture on the Dishwasher Button's topic: single arms the
        # dishwasher in dishwasher_reminder.nix, double queues the robovac in
        # robovac_schedule.nix, triple holds the pump on for washing up here.
        # Three subscriptions on one topic, so no automation has to know about
        # the others' gestures. Triple rather than hold deliberately — hold can
        # swallow a slow single press, and single is the gesture in daily use.
        (
          triggers.mqtt {
            topic = entities.dishwasher.topic;
            value_template = "{{ value_json.action | default('') }}";
            payload = "triple";
          }
          // {
            id = "boost";
          }
        )

        (
          triggers.event {
            event_type = "timer.finished";
            event_data.entity_id = recircPump.boost;
          }
          // {
            id = "boost_done";
          }
        )

        (triggers.homeAssistantStart // { id = "reconcile"; })
      ];

      action = [
        {
          choose = [
            # First, and unconditional: 23:00 and arming away are both hard
            # stops, so a run already under way is cut rather than left to
            # finish past the window or after we have left.
            {
              conditions = [ (firedBy "stop") ];
              sequence = stopCycle;
            }

            # Triple press: hold the pump on for the whole wash. No window
            # check — dishes get done after 23:00 often enough, and the boost
            # ending out of hours falls through to the default and stops.
            {
              conditions = [
                (firedBy "boost")
                (conditions.freshMqttPress maxPressAgeSeconds)
                notArmedAway
                notOnVacation
              ];
              sequence = startBoost;
            }

            # Boost over: drop the banner and hand the pump straight back to the
            # schedule. A boost that ends outside the window, or with the house
            # armed away, misses this and lands on the default instead.
            {
              conditions = [ (firedBy "boost_done") ] ++ shouldCycle;
              sequence = [
                (actions.clearNotification {
                  service = phone;
                  tag = boostTag;
                })
              ]
              ++ runCycle;
            }

            # Anything else arriving mid-boost only re-asserts the switch. This
            # has to sit above the branches below or a bathroom light would arm
            # the cycle timer underneath a wash and flip the pump off partway
            # through. Re-asserting rather than doing nothing also recovers a
            # turn_on the plug dropped.
            {
              conditions = [ boosting ];
              sequence = [
                (actions.switchTurn {
                  entity_id = recircPump.switch;
                  state = "on";
                })
              ];
            }

            # Out of bed. The bedroom sensor also fires walking *in* to go to
            # bed and on every daytime pass through, so the long preceding "off"
            # stretch is what makes this edge mean "slept, now up". The morning
            # bound keeps a late-evening gap — out for dinner, back at 10 — from
            # reading as waking up.
            {
              conditions = [
                (firedBy "woke")
                (conditions.template ''
                  {{ (trigger.to_state.last_changed
                      - trigger.from_state.last_changed).total_seconds()
                     > ${toString sleepGapSeconds} }}
                '')
                (conditions.time {
                  after = "04:00:00";
                  before = "11:00:00";
                })
                notArmedAway
                notOnVacation
              ];
              sequence = runCycle;
            }

            # A bathroom light or someone walking in the door means hot water is
            # wanted now, so these deliberately skip the 5 AM–11 PM window — a
            # midnight trip to the sink still gets a run. It does not leak into
            # an all-night cycle: 15 minutes later the flip branch finds the
            # window closed, falls through to the default, and stops.
            {
              conditions = [
                (firedBy "demand")
                notArmedAway
                notOnVacation
              ];
              sequence = runCycle;
            }

            # The schedule itself. Each expiry flips the pump — on becomes off,
            # off becomes on — and rearms the timer, so one 15-minute timer is
            # the entire 15-on/15-off alternation.
            {
              conditions = [ (firedBy "flip") ] ++ shouldCycle;
              sequence = [
                (actions.switchToggle recircPump.switch)
                (actions.timerStart recircPump.cycle)
              ];
            }

            # 5 AM, a restart, or coming home to a stopped cycle. Keyed on where
            # things currently stand rather than which trigger fired, so one
            # branch restarts the cycle for all of them.
            {
              conditions = shouldCycle;
              sequence = runCycle;
            }
          ];

          # Everything that is not a reason to be running: outside the window,
          # armed away, or vacation mode. Turning off here rather than only on
          # the explicit stops is what makes the cycle self-terminating — a
          # single late-night demand run lands here on its next flip and ends.
          default = stopCycle;
        }
      ];
    })
  ];
}
