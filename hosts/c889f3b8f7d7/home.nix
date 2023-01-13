{ config, options, lib, pkgs, ... }: {

  imports = [
    ../../modules/cli
    ../../modules/shell/zsh
    ../../modules/desktop/term
    ../../modules/desktop/editors
    ../../modules/editors/neovim
  ];

  programs.home-manager.enable = true;

  home.username = "awslucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.sessionPath = [ "$HOME/.toolbox/bin" ];

  #home.activation = {
  #  copyApplications = lib.mkIf pkgs.stdenv.isDarwin (let
  #    apps = pkgs.buildEnv {
  #      name = "home-manager-applications";
  #      paths = config.home.packages;
  #      pathsToLink = "/Applications";
  #    };
  #  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #    baseDir="$HOME/Applications/Home Manager Apps"
  #    if [ -d "$baseDir" ]; then
  #      rm -rf "$baseDir"
  #    fi
  #    mkdir -p "$baseDir"
  #    for appFile in ${apps}/Applications/*; do
  #      target="$baseDir/$(basename "$appFile")"
  #      $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
  #      $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
  #    done
  #  '');
  #};
}
