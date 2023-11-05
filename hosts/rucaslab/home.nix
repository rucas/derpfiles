# The start of something...good?
{ ... }: {
  imports = [
    ../../modules/cli
    ../../modules/shell/zsh
    ../../modules/editors/neovim
  ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "23.05";
}
