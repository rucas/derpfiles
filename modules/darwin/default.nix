{ config, options, lib, pkgs, ... }: {
  imports = [ ./homebrew.nix ./system.nix ./skhd.nix ./spacebar.nix ./yabai.nix ];
}
