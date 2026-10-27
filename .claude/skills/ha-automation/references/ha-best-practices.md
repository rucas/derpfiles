# Home Assistant automation best practices

Read at the design step. Distilled from the Home Assistant automation docs and the
upstream `homeassistant-ai/skills` best-practices pack, filtered to what applies to a
Nix-declared config. Version gates are written out because `rucaslab` tracks whatever
nixpkgs pins — check the actual version before relying on a `202x.y+` feature.

## The core principle

**Native constructs over templates.** A `numeric_state` condition is validated when the
config loads and treats `unavailable` as false. The equivalent Jinja template is parsed
at load but evaluated at runtime, where a missing entity raises and the automation dies
mid-run with nothing but a log line. Reach for a template only when nothing native fits.

Order of preference for every trigger and condition:

1. A purpose-specific trigger/condition (`motion`, `door`, `battery`, …; 2026.7+). They
   target an entity, **area, floor or label**, so an area target picks up a new sensor
   without an edit.
2. A generic native trigger/condition (`state`, `numeric_state`, `time`, `zone`, `sun`,
   `event`, `mqtt`, `template` as a condition).
3. A template.

Common swaps:

| Instead of                                            | Use                                            |
| ----------------------------------------------------- | ---------------------------------------------- |
| `{{ states('sensor.x') \| float > 20 }}`               | `numeric_state` condition with `above: 20`     |
| `{{ is_state('a','on') and is_state('b','on') }}`      | `and` of two `state` conditions                |
| `{{ now().hour >= 22 }}`                               | `time` condition with `after:`                 |
| `state` trigger on a motion/door sensor                | the purpose-specific trigger (2026.7+)         |
| "no motion for N minutes" as a template                | `motion.cleared`, `behavior: all`, `for:`      |

## Modes

`single` is the default and is usually wrong. Pick deliberately:

| Scenario                                 | Mode       |
| ---------------------------------------- | ---------- |
| Motion light with a timeout              | `restart`  |
| Several triggers with contradictory outcomes, or sequential work (locks) | `queued` |
| Independent per-entity work              | `parallel` |
| One-shot notification                    | `single`   |

- `single` logs a warning and **drops** the second run. Add `max_exceeded: silent` only
  when dropping is the intent (the documented throttle pattern: `single` + a trailing
  delay).
- `restart` cancels a running delay or wait mid-flight. That is the point for motion
  lights, and a hazard anywhere the sequence must finish.
- `queued` defaults to `max: 10`. Conditions are re-tested when a queued run starts, not
  when it was queued.
- Nothing survives a restart: a `for:` timer, a `delay`, and a `wait_for_trigger` are
  all abandoned when Home Assistant reloads. Anything that must outlive a restart needs
  a `timer` entity or an `input_*` helper, not a `delay`.

## `unavailable` and `unknown`

Restarts and integration reconnects push entities through `unavailable`/`unknown`, and
the transition back out looks exactly like a real change. An unguarded trigger fires on
a value that never actually moved.

- Filter at the trigger with `not_from: ["unavailable", "unknown"]` rather than in a
  condition — the trigger never fires, so there is nothing to debug.
- Guard both sides when the transition matters: check `trigger.from_state` as well as
  `to_state`.
- `numeric_state` already treats `unavailable` as false; a template comparing the same
  value raises instead.
- Exception: `event.*` entities hold a timestamp and start at `unknown` after a restart,
  so filtering `unknown` there drops the first real event.
- A bare `state` trigger with no `to:` fires on **attribute** changes too. Set `to:` (or
  an explicit empty `to:`) to limit it to state changes.

## Entity ids, never device ids

A `device_id` is a registry uuid: re-pairing a device mints a new one and every
automation referencing the old one goes unavailable. Use `entity_id`. The documented
exceptions are ZHA (`device_ieee` on an `event` trigger) and Zigbee2MQTT autodiscovered
device triggers.

Buttons and remotes, in order:

- Integration exposes an `event.*` entity → `event.received` on that entity.
- ZHA → `event` trigger with `device_ieee`.
- Zigbee2MQTT → a `device` trigger or an `mqtt` trigger on the device's topic. Event
  entities there are experimental and off by default.

**Zigbee2MQTT retains the last payload**, so Home Assistant replays it on every restart
and broker reconnect — an `mqtt`-triggered automation re-fires a press from hours ago.
Guard it on payload freshness (`conditions.freshMqttPress` in this repo's
`lib/helpers.nix`) or the automation will fire itself at boot.

## Trigger ids and `choose`

With more than one trigger, tag each (`id:`) and branch on
`{ condition: trigger, id: ... }` in a `choose`. Two rules of thumb:

- Branch on **state** rather than on which trigger fired where the automation is meant
  to reconcile — then a `homeassistant`/`start` trigger can run the same branch and fix
  whatever drifted while Home Assistant was down. `doorbell_chime.nix` is this shape.
- Branch on **trigger id** where the triggers genuinely mean different things, and order
  the branches so the hard stops come first. `hot_water_recirc.nix` is this shape.

Give every multi-trigger automation a `homeassistant`/`start` trigger unless there is a
reason not to: restarts are frequent, and an automation that only reacts to edges leaves
the house in whatever state the restart found.

## Helpers

Prefer a built-in helper to a template sensor:

| Need                     | Helper          |
| ------------------------ | --------------- |
| Sum or average           | `min_max`       |
| Any-on / all-on          | `group`         |
| Rate of change           | `derivative`    |
| Threshold crossing       | `threshold`     |
| Consumption tracking     | `utility_meter` |

A `group` over flaky sensors is also the fix for members that sit at `unknown` — it
ignores them, where a condition over each raw state stalls. This repo declares helpers
in `nixos/home-assistant/helpers.nix`; an `input_*` helper that must survive a restart
must omit `initial`, or it resets to that value on every reload.

To snapshot and restore device state, use `scene.create` with `snapshot_entities`
followed by `scene.turn_on` — not hand-copied values in variables. The exception is a
device that reports null while off (a thermostat's setpoint), which has to be captured
on the way down into `input_*` helpers.

## Version-gated things that bite

- `color_temp` in mireds — **removed 2026.3**. Use `color_temp_kelvin`
  (kelvin = 1000000 / mireds).
- Person/device-tracker `entered_home` / `left_home` triggers and the `is_home`
  condition — **removed 2026.5**. Use `state` triggers and conditions, or a `zone`
  trigger.
- Purpose-specific triggers/conditions with area/floor/label targets — **2026.7+**.
  `behavior: any`/`last` were renamed to `each`/`all`.
- Add-ons are called **Apps** from 2026.2.
- `vacuum.send_command` with vendor room ids → `vacuum.clean_area` with HA area ids.

## Syntax: the modern keys

Since 2024.10 the top-level keys are plural — `triggers:`, `conditions:`, `actions:` —
and within each item `platform:` became `trigger:` (2024.10) and `service:` became
`action:` (2024.8). The singular/legacy forms still work and are explicitly **not**
deprecated; this repo's `lib/helpers.nix` still emits `platform:` and `service:`. Do not
mix the two forms in the same place (an automation cannot have both `trigger:` and
`triggers:`). Match whatever the helper you are using already emits rather than
hand-mixing a modern key into a legacy structure.

## Anti-patterns, short list

- `wait_for_trigger` on a state that may already hold — a state trigger only fires on a
  transition, so use `wait_template`.
- A `numeric_state` trigger driving something expensive, with no `unavailable`/`unknown`
  guard on `trigger.from_state`.
- `enabled: false` at the top level of an automation — invalid; it loads as unavailable.
  Disable via `automation.turn_off` or the entity registry.
- Renaming an entity or an automation `id` without an impact pass — dashboards, scripts,
  scenes, groups and config-entry data all reference them by id and break silently.
- Repeated Jinja copy-pasted across automations. Once native options are ruled out, move
  it into a macro under `config/custom_templates/*.jinja`; macros do not inherit the
  caller's scope, so pass `trigger`, `this` and so on as arguments.

## Sources

- [Automation modes](https://www.home-assistant.io/docs/automation/modes/)
- [Automations in YAML](https://www.home-assistant.io/docs/automation/yaml/)
- [Actions in automations and scripts](https://www.home-assistant.io/docs/automation/action/)
- [2024.10 release notes — plural keys](https://www.home-assistant.io/blog/2024/10/02/release-202410/)
- [Why and how to avoid device_ids](https://community.home-assistant.io/t/why-and-how-to-avoid-device-ids-in-automations-and-scripts/605517)
- [Hardening automations against unavailable states](https://blog.zackwag.com/hardening-home-assistant-automations-against-unavailable-states)
- [homeassistant-ai/skills — home-assistant-best-practices](https://github.com/homeassistant-ai/skills/blob/main/skills/home-assistant-best-practices/SKILL.md)
- [ha-mcp tool explorer](https://homeassistant-ai.github.io/ha-mcp/tools/)
