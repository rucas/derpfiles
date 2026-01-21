{ lib, ... }: {

  imports = [ ../../modules/darwin ];

  networking.hostName = "blkmrkt";

  # Disable GPG agent for blkmrkt - use native macOS SSH agent for FIDO2 support
  programs.gnupg.agent.enable = lib.mkForce false;

  nix.enable = false;

  # nix.extraOptions = ''
  #   auto-optimise-store = true
  #   experimental-features = nix-command flakes
  # '';
  #
  nix.settings.trusted-users = [ "@admin" ];

  # TODO: better way to do users.users?
  users.users.lucas = { home = "/Users/lucas"; };

  # NOTE: needed or else correct zsh path wont be set
  # correct path is /etc/profiles/per-user/lucas/bin/zsh
  # needs to be in nix-darwin config or else it goes to /bin/zsh osx default
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # TouchID sudo
  # NOTE: does not work with tmux
  # https://github.com/LnL7/nix-darwin/pull/1020
  # security.pam.enableSudoTouchIdAuth = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "lucas";
}
