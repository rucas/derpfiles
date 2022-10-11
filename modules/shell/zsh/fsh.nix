{ config, options, lib, pkgs, ... }: {
  programs.zsh = {
    initExtra = ''
      fast-theme -q base16
      # make zsh-syntax-highlighting comments easier to see
      # typeset -gA ZSH_HIGHLIGHT_STYLES
      # FAST_HIGHLIGHT_STYLES[comment]=fg=240,bold
    '';
    sessionVariables = { FAST_WORK_DIR = "$HOME/.cache/fsh"; };
    plugins = [{
      name = "fast-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zdharma-continuum";
        repo = "fast-syntax-highlighting";
        rev = "13dd94ba828328c18de3f216ec4a746a9ad0ef55";
        sha256 = "sha256-Vc/i0W+beKphNisGFS435r+9IL6BhQsYeGAFRlP8+tA=";
      };
    }];
  };

  home.activation.createFstCache =
    let inherit (config.programs.zsh.sessionVariables) FAST_WORK_DIR;
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -e "${FAST_WORK_DIR}" ]
      then
        if [ -d "${FAST_WORK_DIR}" ] && [ -w "${FAST_WORK_DIR}" ]
        then
          $VERBOSE_ECHO "FSH working directory exists and is writeable: ${FAST_WORK_DIR}"
        else
          errorEcho "FSH working directory (${FAST_WORK_DIR}) must be a writeable directory"
          exit 1
        fi
      else
        $VERBOSE_ECHO "Creating FSH working directory: ${FAST_WORK_DIR}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG "${FAST_WORK_DIR}"
      fi
    '';
}
