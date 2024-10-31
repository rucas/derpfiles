{ pkgs, ... }: {

  imports = [
    ../../modules/cli
    ../../modules/desktop/browsers
    ../../modules/desktop/editors
    ../../modules/desktop/productivity
    ../../modules/desktop/term
    ../../modules/editors/neovim
    ../../modules/shell/zsh
    # ../../modules/security
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  programs.home-manager.enable = true;

  home.username = "awslucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages =
    [ (import ../../pkgs/dnd pkgs) (import ../../pkgs/shortuuid pkgs) ];

  home.sessionPath = [ "$HOME/.toolbox/bin" ];

}
