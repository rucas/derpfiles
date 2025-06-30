{ pkgs, lib, ... }: {
  imports = [
    ./autopairs.nix
    ./fsh.nix
    ./starship.nix
    ./zsh-lazyload.nix
    ./zsh-vi-mode.nix
  ];
  programs.zsh = {
    enable = true;
    history = {
      ignorePatterns =
        [ "rm *" "pkill *" "touch *" "which *" "man *" "tldr *" ];
      expireDuplicatesFirst = true;
      extended = true;
    };
    autocd = true;
    autosuggestion = { enable = true; };
    shellAliases = {
      cat = "bat -n --paging=never";
      g = "git";
      j = "jobs";
      zreload = "source ~/.zshenv && source ~/.zshrc";
      v = "nvim";
    };
    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat --theme=base16-256 -l man -p'";
      MANROFFOPT = "-c";
    };
    shellGlobalAliases = {
      F = "| fzf";
      G = "| grep";
      J = "| jq ";
      L = "| less";
      R = "| rg";
      W = "| wc -l";
    };
    initContent = ''
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        export PATH="/opt/homebrew/bin:$PATH"
        export PATH="/opt/homebrew/sbin:$PATH"
      ''}
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

      #fpath=(
      #  ~/.zfuncs
      #  ~/.zfuncs/**/*~*/(CVS)#(/N)
      #  "''${fpath[@]}"
      #)
      ## automagically load zfuncs
      #autoload -Uz $fpath[1]/*(.:t)

      # reverse tab completion with shift-tab
      bindkey '^[[Z' reverse-menu-complete
    '';

  };

  home.file.".zfuncs" = {
    source = ./zfuncs;
    recursive = true;
  };
}
