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
    userName = "rucas";
    userEmail = "lucas.rondenet@gmail.com";
    ignores = [ ".DS_Store" ];
    aliases = {
      l =
        "log --pretty=format:'%h - %an, %an : %s' -n 20 --graph --abbrev-commit";
      conflicts = "diff --name-only --diff-filter=U";
      contributors = "shortlog --summary --numbered";
      dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
    };
  };
}
