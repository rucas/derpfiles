{ pkgs, ... }: {

  imports = [
    ../../modules/cli
    ../../modules/desktop/browsers
    ../../modules/desktop/editors
    ../../modules/desktop/productivity
    ../../modules/desktop/term
    ../../modules/editors/neovim
    ../../modules/shell/zsh
  ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages =
    [ (import ../../pkgs/dnd pkgs) (import ../../pkgs/shortuuid pkgs) ];
}
