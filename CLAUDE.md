# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Flake-based Nix configuration for the author's machines: **nix-darwin** for
macOS hosts and **NixOS** for the `rucaslab` server, with **home-manager**
integrated as a submodule of each system (not standalone). Built with
`flake-parts`. Uses **Determinate Nix** on darwin.

## Commands

Enter the dev shell first (`just`, `nixd`, `statix`, `deadnix`, pre-commit hooks);
direnv auto-loads it via `.envrc`:

```sh
nix develop
```

Common tasks are wrapped in the `justfile` (run `just` to list them):

```sh
just build [HOST]    # build a host's system without activating (defaults to `hostname -s`)
just switch [HOST]   # build and activate (darwin-rebuild on macOS, sudo nixos-rebuild on Linux)
just check           # nix flake check — statix, deadnix, treefmt, and host evals
just fmt             # format the tree with treefmt (nixfmt, prettier, shfmt, taplo)
just update [INPUT]  # nix flake update (all inputs, or one)
just update-pkg ATTR # bump one hand-pinned pkgs/ package via nix-update
```

`just switch`/`build` on darwin pass `--impure` (home config reads absolute
paths). Verify a host evaluates without activating:

```sh
nix eval --raw '.#darwinConfigurations.<host>.system.outPath'
nix eval --raw '.#nixosConfigurations.rucaslab.config.system.build.toplevel.outPath'
```

There is no unit-test suite — `nix flake check` (evaluation + statix + deadnix +
treefmt) and the per-host builds are the correctness gate.

## Architecture

**Host factory.** Hosts are declared once in the `hosts` table in `flake.nix`
(each entry: `username`, `arch`, `env` = `darwin`|`nixos`). `flake-modules/hosts.nix`
turns that table into `darwinConfigurations`/`nixosConfigurations`:

- `mkCommonModule host cfg` — config shared by every host: nixpkgs overlays,
  binary caches (the `cachixSubstituters`/`cachixKeys` let-bindings feed both
  `nix.settings` for NixOS and, on darwin, the `nix.custom.conf` text since
  Determinate Nix ignores `nix.settings`), the home-manager submodule, and (darwin
  only, via `lib.optionalAttrs`) `users.users.<username>` + `system.primaryUser`
  derived from `cfg.username`.
- `mkSystemConfig` — wires `specialArgs` (`CONF` = parsed `hosts/configs.toml`,
  `inputs`) and assembles the module list per platform. Per-host modules live in
  `hosts/<host>/` (`darwin.nix`/`configuration.nix`, `home.nix`, optional
  `secrets.nix` imported only if present).

**Modules** (`modules/`) are small, single-purpose home-manager/darwin modules
grouped by domain (`cli/`, `darwin/`, `desktop/`, `security/`, `services/`,
`shell/`, `themes/`) and aggregated via `default.nix` import lists. A few expose
`mkEnableOption`/`mkOption` toggles (`modules/cli/claude`, `modules/services/git-wt`,
`modules/services/ledger-sync`, `nixos/zwave-js-ui`); most are plain config.
home-manager receives a `theme` arg (parsed from `modules/themes/gruvbox.toml`).

**NixOS services** (`nixos/`) are the self-hosted stack for `rucaslab`
(home-assistant, caddy, grafana, authelia, etc.), imported by
`hosts/rucaslab/configuration.nix`.

**Custom packages** (`pkgs/`) are derivations (MCP servers, yabai, gitui, Lovelace
cards, …) wired into `pkgs` through the single overlay in `overlays/default.nix`,
which also pulls in `inputs` overlays.

**Secrets** use three mechanisms: **git-crypt** (repo-wide, `secrets/**` per
`.gitattributes`), **agenix** (NixOS), and **opnix** (1Password) — do not commit
decrypted secret material.

## Nix style

- **Avoid `with lib;` and `with pkgs;`.** They obscure where a name comes from,
  shadow lambda/`let` bindings, and hide identifiers from static tooling (deadnix,
  the nixd LSP). Prefer:
  - `inherit (lib) mkIf mkOption ...;` in a module's `let` block,
  - `lib.`-qualified refs in derivation `meta` (`lib.licenses.mit`,
    `[ lib.maintainers.rucas ]`, `lib.platforms.darwin`),
  - `pkgs.`-prefixed entries in package lists (`[ pkgs.ripgrep pkgs.fd ]`).
  - Narrowly-scoped `with` on other sets (`with types;`, `with maintainers;`) is fine.
- Module signatures use `_:` when no args are consumed (statix flags `{ ... }:`).
- `nix fmt` (treefmt) formats Nix/shell/YAML/TOML/JSON but **not** Markdown (prettier
  excludes `*.md`); statix + deadnix run as pre-commit/`nix flake check` linters.

## CI

`.github/workflows/`: `check.yaml` (`nix flake check`) and `build.yaml` (per-host
`nix build`) both run `on: push` across ubuntu + macOS, posting per-job status
checks. `update.yml` opens a weekly flake-bump PR and merges it with
`gh pr merge --auto`. `update-pkgs.yaml` does the same job for the hand-pinned
packages flakes don't cover (see **Package updates** below). `master` is
branch-protected requiring the `check (*)` and `build (*)` contexts, so a bump
can't merge unless every host evaluates, builds, and lints clean. When
adding/removing a host, update both the `build.yaml` matrix and the required
branch-protection contexts.

## Package updates

`update-pkgs.yaml` runs weekly, bumps `pkgs/` entries with `nix-update`, and
opens one PR per package (label `nix-deps` plus `pkg:<attr>`), capped at five
open at a time. `.github/nix-update.json` drives it: every package listed there
is auto-bumped on the runner it names, and everything else exposed in
`packages.<system>` must carry a written reason under `skip`. The
`update-coverage` flake check enforces that, so a new `pkgs/` entry has to be
either wired into the updater or explicitly excused.

Two constraints shape it:

- `nix-update --flake` resolves `packages.<system>.<attr>`, so every pinned
  package is exposed in `flake.nix`'s `packages` output even when nothing else
  needs it there.
- Determinate Nix's lazy trees give each source file its own store path, which
  defeats nix-update's check that a package is defined inside the flake. Both
  the `just update-pkg` recipe and the workflow set
  `NIX_CONFIG="lazy-trees = false"`.

Packages pinned to a `rev`/`version` that `nix-update` cannot rewrite (a bare
commit sha, a `v`-prefixed `version` feeding `rev = version`) must be
normalised to `version = "1.2.3"` + `tag = "v${version}"` first.
