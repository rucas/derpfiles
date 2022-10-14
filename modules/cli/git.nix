{ config, options, lib, pkgs, ... }: {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        line-numbers = true;
      };
    };
    ignores = [ ".DS_Store" ];
    includes = [
      {
        path = "~/.config/git/public.gitconfig";
        condition = "gitdir:~/Code/";
      }
      {
        path = "~/.config/git/work.gitconfig";
        condition = "gitdir:~/Work/";
      }
    ];
    aliases = {
      l =
        "log --pretty=format:'%h - %an, %an : %s' -n 20 --graph --abbrev-commit";
      conflicts = "diff --name-only --diff-filter=U";
      contributors = "shortlog --summary --numbered";
      dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
    };
  };

  home.file.".config/git/work.gitconfig".text = ''
    [user]
        email = awslucas@amazon.com
        name = Lucas Rondenet
  '';
  home.file.".config/git/public.gitconfig".text = ''
    [user]
        email = lucas.rondenet@gmail.com
        name = rucas
  '';
}
