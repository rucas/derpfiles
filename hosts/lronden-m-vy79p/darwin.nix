{ ... }: {

  imports = [ ../../modules/darwin ];

  nix.enable = false;

  nix.settings.trusted-users = [ "@admin" ];

  # TODO: better way to do users.users?
  users.users = {
    "lucas.rondenet" = {
      name = "lucas.rondenet";
      home = "/Users/lucas.rondenet";
    };
  };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
