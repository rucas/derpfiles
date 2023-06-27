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

  home.packages = [
    #   # (lib.mkIf pkgs.stdenv.isDarwin (import ../../pkgs/dnd pkgs))
    #   # (import ../../pkgs/dnd { inherit pkgs; })
    #   # (import ../../pkgs/dnd pkgs).dnd
    (import ../../pkgs/dnd pkgs)
    #   # (import ../../pkgs/nah pkgs)
  ];

  home.sessionPath = [ "$HOME/.toolbox/bin" ];
}
