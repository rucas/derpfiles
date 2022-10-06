{ config, lib, pkgs, ... }: {
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lucas";
  # home.homeDirectory = "/Users/lucas";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    bandwhich
    calc
    curl
    du-dust
    fd
    grex
    htop
    hyperfine
    inetutils
    jq
    m-cli
    nixfmt
    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" ]; })
    # procs NOTE: broken
    ripgrep
    tmux
    tree
    wget
    yq
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "0x282828";
          foreground = "0xd4be98";
        };
        normal = {
          black = "0x3c3836";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
        bright = {
          black = "0x3c3836";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
      };
      cursor = {
        style = {
          shape = "Underline";
          blinking = "On";
        };
        vi_mode_style = "Block";
      };
      window.padding = {
        x = 45;
        y = 45;
      };
      use_thin_strokes = true;
      window.dynamic_title = true;
      window.decorations = "none";
      font = {
        normal = {
          family = "Hack Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "Hack Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "Hack Nerd Font";
          style = "Italic";
        };
        size = 12;
      };
      mouse.hide_when_typing = true;
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
    };
  };

  programs.exa = { enable = true; };

  programs.fzf = { enable = true; };

  programs.gh = { enable = true; };

  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        line-numbers = true;
      };
    };
    userName = "rucas";
    userEmail = "lucas.rondenet@gmail.com";
    ignores = [ ".DS_Store" ];
  };

  programs.gitui = { enable = true; };

  programs.tealdeer = { enable = true; };

  programs.starship = {
    enable = true;
    settings = {
      git_branch = {
        style = "purple";
        symbol = "";
      };
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [ bbenoist.nix vscodevim.vim brettm12345.nixfmt-vscode ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "gruvbox-material";
        publisher = "sainnhe";
        version = "6.5.1";
        sha256 = "sha256-+JU/pwIFmrH8wXqC9hh59iJS22zs7ITYhEwWf676RJU=";
      }];
    userSettings = {
      "workbench.colorTheme" = "Gruvbox Material Dark Medium";
      "editor.formatOnSave" = true;
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      cursor_shape = "beam";
      font_size = 12;
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "JetBrainsMono Nerd Font Bold";
      italic_font = "JetBrainsMono Nerd Font Italic";
      bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";
      window_padding_width = 45;
      hide_window_decorations = "yes";
      macos_thicken_font = "0.6";
    };
    theme = "Gruvbox Material Dark Medium";
  };

  programs.zsh = {
    enable = true;

    history = {
      ignorePatterns =
        [ "rm *" "pkill *" "touch *" "which *" "man *" "tldr *" ];
      expireDuplicatesFirst = true;
      extended = true;
    };
    autocd = true;
    #enableAutosuggestions = true;
    #enableSyntaxHighlighting = true;
    shellAliases = {
      cat = "bat --paging=never";
      h = "history";
      j = "jobs";
      ls = "exa --group-directories-first";
      la = "exa --group-directories-first -a";
    };
    shellGlobalAliases = { G = "| grep"; };
    initExtraFirst = "";
    initExtra = ''
      fast-theme -q base16
      # make zsh-syntax-highlighting comments easier to see
      # typeset -gA ZSH_HIGHLIGHT_STYLES
      # FAST_HIGHLIGHT_STYLES[comment]=fg=240,bold

      setopt EXTENDED_GLOB

      # Prohibit overwrite by redirection(> & >>) (Use >! and >>! to bypass.)
      setopt NO_CLOBBER

      # Confirm when executing 'rm *'
      setopt RM_STAR_WAIT

      # Allow comments even in interactive shells.
      setopt INTERACTIVE_COMMENTS

      # Remove command of 'history' or 'fc -l' from history list
      setopt HIST_NO_STORE

      # Expire a duplicate event first when trimming history.
      setopt HIST_EXPIRE_DUPS_FIRST   

      # Delete an old recorded event if a new event is a duplicate.
      setopt HIST_IGNORE_ALL_DUPS  

      # When writing out the history file, older commands that duplicate newer ones are omitted.
      setopt HIST_SAVE_NO_DUPS

      # Clean up blanks from when adding to history list.
      setopt HIST_REDUCE_BLANKS

      # Do not display a previously found event.
      setopt HIST_FIND_NO_DUPS

      # Do not execute immediately upon history expansion.
      # sudo !! (!! is expanded on first enter, second enter executes)
      setopt HIST_VERIFY

      zshaddhistory() {
        emulate -L zsh
        setopt extendedglob 
        [[ $1 != ''${~HISTORY_IGNORE} ]]
      }
    '';
    plugins = [{
      name = "fast-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zdharma-continuum";
        repo = "fast-syntax-highlighting";
        rev = "13dd94ba828328c18de3f216ec4a746a9ad0ef55";
        sha256 = "sha256-Vc/i0W+beKphNisGFS435r+9IL6BhQsYeGAFRlP8+tA=";
      };
    }];
    sessionVariables = { FAST_WORK_DIR = "$HOME/.cache/fsh"; };
  };

  home.activation = {
    copyApplications = lib.mkIf pkgs.stdenv.isDarwin (let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      baseDir="$HOME/Applications/Home Manager Apps"
      if [ -d "$baseDir" ]; then
        rm -rf "$baseDir"
      fi
      mkdir -p "$baseDir"
      for appFile in ${apps}/Applications/*; do
        target="$baseDir/$(basename "$appFile")"
        $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
        $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
      done
    '');
    createFastSyntaxHighlightingCache =
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
  };
}
