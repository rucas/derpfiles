{ inputs, ... }:
{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        line-numbers = true;
      };
    };
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
    aliases = {
      conflicts = "diff --name-only --diff-filter=U";
    };
    extraConfig = {
      core = {
        editor = "nvim";
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
  '';
}
