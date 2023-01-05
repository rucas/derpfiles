{ config, options, lib, pkgs, ... }: {
  imports = [ ./homebrew.nix ./system.nix ./spacebar.nix ./yabai.nix ];
}
