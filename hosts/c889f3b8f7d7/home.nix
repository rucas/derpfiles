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

  home.username = "awslucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages = [ (import ../../pkgs/dnd pkgs) ];

  home.sessionPath = [ "$HOME/.toolbox/bin" ];

  home.sessionVariables = { SSH_AUTH_SOCK = "/Users/awslucas/.ssh/agent"; };

}
