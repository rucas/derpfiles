---
name: ha-automation
description: Write or change a Home Assistant automation in this repo's Nix DSL — discover real entity ids over the HA MCP, build it from nixos/home-assistant/lib, evaluate it, and verify the deployed run from its trace. Never writes automations into Home Assistant itself.
---

# Home Assistant automations in Nix

Automations here are Nix, not YAML. They live in `nixos/home-assistant/automations/`,
are built from the DSL in `nixos/home-assistant/lib/`, and reach Home Assistant only
through `nixos-rebuild`. `$ARGUMENTS` is the automation to write or change — a sentence
of intent, or the name of an existing file.

**The hard rule: never create or edit an automation through the Home Assistant MCP.**
`ha_config_set_automation`, `ha_config_set_helper`, `ha_config_set_scene`,
`ha_config_set_yaml` and friends write into `.storage`/`automations.yaml`, which this
repo does not manage. The next `nixos-rebuild` will not remove it, so the result is a
silent duplicate firing alongside the Nix one. The MCP is for **reading** — entity
discovery, state, history, traces, template evaluation — and for `ha_call_service` when
manually exercising a device.

The repo config and `nixos/home-assistant/BLUEPRINTS.md` are already in context; let
them govern. Read `references/ha-best-practices.md` at step 3 — not before.

## Steps

1. **Pin the facts.** The host is `rucaslab`; Home Assistant is pinned by nixpkgs, so
   read the version rather than assuming it:

   ```sh
   nix eval --raw '.#nixosConfigurations.rucaslab.config.services.home-assistant.package.version'
   ```

   Several best practices are version-gated (purpose-specific triggers landed in
   2026.7, `color_temp` mireds went away in 2026.3, person `entered_home` in 2026.5).

2. **Find the real entity ids.** Never invent one, and never copy one from a dashboard
   screenshot. Use `ha_search` to fuzzy-match by name/domain/area, `ha_get_state` to
   confirm the entity exists and see its current attributes, `ha_list_services` for the
   exact service and its data schema, and `ha_get_history` when you need to know how an
   entity actually behaves (does it sit at `unknown` after a restart? does it flap?).

   Then check `nixos/home-assistant/lib/entities.nix`. If the entity is already named
   there, use the name — its comments record why an id is what it is. If it is not,
   add it there rather than inlining a raw string, and carry over whatever you learned
   about the device as a comment.

   Without the MCP (it is only enabled on `blkmrkt` and `rucaslab`), stop and ask for
   the entity ids rather than guessing.

3. **Design the automation.** Read `references/ha-best-practices.md` now and apply it:
   native constructs over templates, the right `mode`, entity ids over device ids,
   guards for `unavailable`/`unknown`, a reconcile path for Home Assistant restarts.

4. **Write it in the DSL.** One automation per file in `automations/`, added to the
   `imports` list in `automations/default.nix`, emitting into
   `services.home-assistant.config."automation manual"`.

   Read `lib/helpers.nix` and `lib/builders.nix` before writing — they are the API and
   they change. Do not duplicate a helper that exists; if a trigger or action shape is
   missing, add it to `helpers.nix` so the next automation gets it too. Note that
   `lib/default.nix` re-exports only some builders — `mkSunAutomation`, `mkScene` and
   `mkNotifyGroup` are reached as `haLib.builders.<name>`.

   `mkMultiTriggerAutomation` is the one to reach for whenever there is more than one
   trigger: tag each trigger with `// { id = "..."; }` and branch on
   `{ condition = "trigger"; id = ...; }` inside a `choose`. `hot_water_recirc.nix` is
   the worked example of the whole pattern.

   The `id` is the automation's permanent handle — stable snake_case, never reused,
   never renamed once deployed (renaming it orphans the entity and its history).

5. **Comment the why, not the what.** This directory's comments carry the hard-won
   facts — that Zigbee2MQTT replays retained payloads on reconnect, that UniFi Protect
   drops its privacy-restore, that a stalled device tracker reads `home` forever. A
   comment restating the code is noise; a comment recording a device's misbehaviour is
   the reason the automation is shaped the way it is. If a quirk made you choose one
   construct over another, write it down.

6. **Evaluate.** Nix catches the structural mistakes before Home Assistant ever sees
   them:

   ```sh
   nix eval --raw '.#nixosConfigurations.rucaslab.config.system.build.toplevel.outPath'
   just check
   just fmt
   ```

   `nix eval` is the fast loop; `just check` runs statix/deadnix/treefmt and every host.
   Both are local and safe to run unprompted.

7. **Deploy — ask first.** `just switch rucaslab` restarts Home Assistant and is the
   user's call, from `rucaslab` itself. Stop here and say what is ready unless the user
   has already told you to deploy.

8. **Verify the live run.** Once deployed, do not declare it working off a successful
   build. Trigger it — `ha_call_service` on the input, or `automation.trigger` for a
   dry run — then read `ha_get_automation_traces` for that automation id: it shows
   which branch of the `choose` was taken and which conditions blocked. `ha_get_logs`
   catches template errors that evaluated to nothing. `ha_eval_template` checks a Jinja
   expression against live state before you trust it.

## What this skill will not do

- Write anything into Home Assistant that outlives a `nixos-rebuild` (see the hard rule)
- Run `just switch`, or restart Home Assistant, without being asked
- Rename or remove an existing automation `id`, or an entity id in `entities.nix`,
  without flagging what it breaks — dashboards, scripts, scenes and history all
  reference them by id and fail silently
