# Contributing

This is a Nix flake managing macOS (nix-darwin) and NixOS hosts with
home-manager. See [CLAUDE.md](CLAUDE.md) for the layout and conventions.

## Getting started

```sh
nix develop   # dev shell: just, nixd, statix, deadnix, and the pre-commit hooks
just          # list available tasks
```

## Making changes

- Follow the Nix style in [CLAUDE.md](CLAUDE.md) — notably, avoid `with lib;` /
  `with pkgs;` (prefer `inherit (lib) ...` and explicit refs).
- Format and lint before committing:

  ```sh
  just fmt      # treefmt: nixfmt, prettier, shfmt, taplo
  just check    # nix flake check: statix, deadnix, treefmt, host evals
  ```

- Verify an affected host still evaluates/builds:

  ```sh
  just build <host>
  ```

## CI

Every push runs `nix flake check` and a per-host `nix build` on ubuntu and
macOS. `master` is protected — those checks must pass before a change merges.
