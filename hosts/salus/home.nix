{ pkgs, inputs, ... }:
{

  imports = [
    ../../modules/cli
    ../../modules/desktop/browsers
    ../../modules/desktop/editors
    ../../modules/desktop/productivity
    ../../modules/desktop/term
    ../../modules/shell/zsh
    ../../modules/security
  ];

  programs.home-manager.enable = true;

  home.username = "lucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages = [
    (import ../../pkgs/dnd pkgs)
    (import ../../pkgs/shortuuid pkgs)
    inputs.nxvm.packages.${pkgs.system}.default
  ];

  # NOTE: used for nvim
  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";
}
