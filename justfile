host := `hostname -s`
rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }
impure := if os() == "macos" { "--impure" } else { "" }

# Determinate Nix's lazy trees give each source file its own store path, which
# defeats the check nix-update makes that a package is defined inside the flake.
nix_update := 'NIX_CONFIG="lazy-trees = false" nix-update'

# List available recipes
default:
    @just --list

# Build a host's system configuration without activating it
build host=host:
    {{ rebuild }} build --flake ".#{{ host }}" {{ impure }}

# Build and activate a host's system configuration
switch host=host:
    sudo "$(command -v {{ rebuild }})" switch --flake ".#{{ host }}" {{ impure }}

# Run all flake checks (statix, deadnix, treefmt, host evals)
check:
    nix flake check

# Format the tree with treefmt
fmt:
    nix fmt

# Update all flake inputs, or a single INPUT (e.g. `just update nixpkgs`)
update input="":
    nix flake update {{ input }}

# Bump a hand-pinned package to its latest upstream release (e.g. `just update-pkg crw`)
update-pkg attr:
    {{ nix_update }} --flake --build {{ attr }}
    nix fmt
