{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ vim ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  nix.trustedUsers = [ "@admin" ];

  #nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  users.users.lucas = { home = "/Users/lucas"; };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults.dock.autohide = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask-fonts" "bradyjoslin/sharewifi" ];
    casks = [ "blackhole-16ch" "obs" "vlc" ];
    brews = [ "sharewifi" ];
  };
}
