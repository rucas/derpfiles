host := `hostname -s`
rebuild := if os() == "macos" { "darwin-rebuild" } else { "sudo nixos-rebuild" }
impure := if os() == "macos" { "--impure" } else { "" }

# List available recipes
default:
    @just --list

# Build a host's system configuration without activating it
build host=host:
    {{ rebuild }} build --flake ".#{{ host }}" {{ impure }}

# Build and activate a host's system configuration
switch host=host:
    {{ rebuild }} switch --flake ".#{{ host }}" {{ impure }}

# Run all flake checks (statix, deadnix, treefmt, host evals)
check:
    nix flake check

# Format the tree with treefmt
fmt:
    nix fmt

# Update all flake inputs, or a single INPUT (e.g. `just update nixpkgs`)
update input="":
    nix flake update {{ input }}
