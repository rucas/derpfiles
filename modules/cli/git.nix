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
  };
}
