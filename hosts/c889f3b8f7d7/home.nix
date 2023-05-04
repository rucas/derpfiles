{ ... }: {

  imports = [
    ../../modules/cli
    ../../modules/shell/zsh
    ../../modules/desktop/term
    ../../modules/desktop/editors
    ../../modules/editors/neovim
    ../../modules/desktop/browsers
    ../../modules/desktop/productivity
  ];

  programs.home-manager.enable = true;

  home.username = "awslucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.sessionPath = [ "$HOME/.toolbox/bin" ];
}
