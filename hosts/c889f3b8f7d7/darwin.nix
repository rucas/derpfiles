{ ... }:
{

  imports = [ ../../modules/darwin ];

  networking.hostName = "c889f3b8f7d7";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    # NOTE: auto-optimise-store disabled for CI (https://github.com/NixOS/nix/issues/7273)
    trusted-users = [ "@admin" ];
    max-jobs = "auto";
    cores = 0;
  };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
