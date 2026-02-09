{ inputs, ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "gruvbox-dark";
      line-numbers = true;
    };
  };
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".direnv"
      ".claude"
      ".env**"
      "*.log"
      "*.min.js"
      "dist/"
      "build/"
      "target/"
    ];
    includes = [
      {
        path = "~/.config/git/public.gitconfig";
        condition = "gitdir:~/Code/";
      }
      {
        path = "~/.config/git/work.gitconfig";
        condition = "gitdir:~/Work/";
      }
      { path = "~/.config/git/gitalias"; }
      { path = "~/.config/git/gitalias.custom"; }
    ];
    settings = {
      aliases = {
        conflicts = "diff --name-only --diff-filter=U";
      };
      # NOTE: https://blog.gitbutler.com/how-git-core-devs-configure-git
      extraConfig = {
        branch = {
          sort = "-committerdate";
        };
        core = {
          editor = "nvim";
        };
        column = {
          ui = "auto";
        };
        commit = {
          verbose = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        help = {
          autocorrect = "prompt";
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        pull = {
          rebase = true;
          autostash = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        tag = {
          sort = "version:refname";
        };
      };
    };
  };

  home.file.".config/git/work.gitconfig".text = ''
    [user]
        email = lucas.rondenet@gmail.com
        name = rucas

    [core]
        fsmonitor = true
        untrackedCache = true
        manyFiles = true
  '';
  home.file.".config/git/public.gitconfig".text = ''
    [user]
        email = lucas.rondenet@gmail.com
        name = rucas
  '';

  home.file.".config/git/gitalias".text = builtins.readFile "${inputs.git-alias}/gitalias.txt";
  home.file.".config/git/gitalias.custom".text = ''
    [alias]
      co = "!f() { \
        if [ $# -eq 0 ]; then \
          git branch -a | grep -v HEAD | \
            sed 's|remotes/origin/||g' | \
            sed 's/^[* ] //' | \
            sort -u | \
            fzf --height=10 --layout=reverse-list --no-info --border=none --prompt='Branch: ' | \
            xargs git checkout; \
        else \
          git checkout \"$@\"; \
        fi; \
      }; f"

      # Pull from origin with optional branch (defaults to current branch)
      # Automatically uses rebase+autostash from global config
      po = "!f() { git pull origin \"''${1:-$(git current-branch)}\"; }; f"
  '';
}
