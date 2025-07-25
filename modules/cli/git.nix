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
}
