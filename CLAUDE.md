# derpfiles

Flake-based Nix config: nix-darwin (macOS hosts) + NixOS (`rucaslab`), with
home-manager as a submodule of each system. Hosts are declared in the `hosts`
table in `flake.nix` and built by `flake-modules/hosts.nix`.

## Nix style

- **Avoid `with lib;` and `with pkgs;`.** They obscure where a name comes from,
  shadow lambda/`let` bindings, and hide identifiers from static tooling
  (deadnix, the nixd LSP). Prefer:
  - `inherit (lib) mkIf mkOption ...;` in a module's `let` block,
  - `lib.`-qualified refs in derivation `meta` (e.g. `lib.licenses.mit`,
    `[ lib.maintainers.rucas ]`, `lib.platforms.darwin`),
  - `pkgs.`-prefixed entries in package lists (e.g. `[ pkgs.ripgrep pkgs.fd ]`).
  - Narrowly-scoped `with` on non-`lib`/`pkgs` sets (`with types;`,
    `with maintainers;`) is fine.

## Workflow

- `just` wraps common tasks: `just build|switch [HOST]`, `just check`,
  `just fmt`, `just update [INPUT]`. `nix develop` (or direnv) drops you into a
  shell with `just`, `nixd`, `statix`, `deadnix`.
- Formatting is treefmt via `nix fmt`; linting is statix + deadnix. Both run in
  `nix flake check` / the pre-commit hook — keep it green.
- After changing a host, verify with `nix eval --raw
  '.#darwinConfigurations.<host>.system.outPath'` (or the nixos equivalent).
