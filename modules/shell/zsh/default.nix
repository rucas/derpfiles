{ config, options, lib, pkgs, ... }: {
  imports = [ ./autopairs.nix ./fsh.nix ./starship.nix ./zsh-vi-mode.nix ];
  programs.zsh = {
    enable = true;
    history = {
      ignorePatterns =
        [ "rm *" "pkill *" "touch *" "which *" "man *" "tldr *" ];
      expireDuplicatesFirst = true;
      extended = true;
    };
    autocd = true;
    enableAutosuggestions = true;
    # enableSyntaxHighlighting = true;
    shellAliases = {
      b = "brazil";
      cat = "bat -n --paging=never";
      g = "git";
      j = "jobs";
      ls = "exa --group-directories-first";
      la = "exa --group-directories-first -a";
      v = "nvim";
    };
    sessionVariables = { MANPAGER = "sh -c 'col -bx | bat -l man -p'"; };
    shellGlobalAliases = {
      G = "| grep";
      J = "| jq ";
      L = "| less";
      W = "| wc -l";
    };
    initExtraFirst = "";
    initExtra = ''
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

      fpath=(
        ~/.zfuncs
        ~/.zfuncs/**/*~*/(CVS)#(/N)
        "''${fpath[@]}"
      )
      # automagically load zfuncs
      autoload -Uz $fpath[1]/*(.:t)
    '';

  };

  home.file.".zfuncs" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/derpfiles/modules/shell/zsh/zfuncs/";
    recursive = true;
  };
}
