{ config, options, lib, pkgs, ... }: {

  imports = [
    ../../modules/cli
    ../../modules/shell/zsh
    ../../modules/desktop/term
    ../../modules/desktop/editors
    ../../modules/editors/neovim
  ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;
}
