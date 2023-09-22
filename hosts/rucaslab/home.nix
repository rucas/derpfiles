# The start of something...good?
{ config, pkgs, home-manager, ... }: {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.lucas = {
    # This should be the same value as `system.stateVersion` in
    # your `configuration.nix` file.
    home.stateVersion = "23.05";
  };
}
