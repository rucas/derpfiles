{ pkgs, ... }: {

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

  home.packages = [ (import ../../pkgs/dnd pkgs) ];

  home.sessionPath = [ "$HOME/.toolbox/bin" ];

  home.sessionVariables = { SSH_AUTH_SOCK = "/Users/awslucas/.ssh/agent"; };

}
