# The start of something...good?
{ pkgs, inputs, ... }: {
  imports =
    [ ../../modules/cli ../../modules/shell/zsh ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "23.05";

  home.packages = [
    (import ../../pkgs/shortuuid pkgs)
    inputs.nxvm.packages.${pkgs.system}.default
  ];

  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";

}
