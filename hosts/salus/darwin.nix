{ ... }: {

  imports = [ ../../modules/darwin ];

  networking.hostName = "salus";

  nix.enable = false;

  nix.settings.trusted-users = [ "@admin" ];

  # TODO: better way to do users.users?
  users.users = {
    lucas = {
      name = "lucas";
      home = "/Users/lucas";
    };
  };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.primaryUser = "lucas";

  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };
}
