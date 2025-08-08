{ ... }: {

  imports = [ ../../modules/darwin ];

  networking.hostName = "c889f3b8f7d7";

  nix.extraOptions = ''
    # NOTE: https://github.com/NixOS/nix/issues/7273
    # auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  nix.settings.trusted-users = [ "@admin" ];

  services.nix-daemon.enable = true;

  # TODO: better way to do users.users?
  users.users.awslucas = {
    name = "awslucas";
    home = "/Users/awslucas";
  };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
