{ ... }:
{

  imports = [ ../../modules/darwin ];

  networking.hostName = "salus";

  nix.enable = false;

  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ "@admin" ];
    max-jobs = "auto";
    cores = 0;
  };

  users.users.lucas.uid = 501;

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };
}
