# The start of something...good?
{ pkgs, ... }: {
  imports =
    [ ../../modules/cli ../../modules/shell/zsh ../../modules/editors/neovim ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "23.05";

  home.packages = [ (import ../../pkgs/shortuuid pkgs) ];

}
