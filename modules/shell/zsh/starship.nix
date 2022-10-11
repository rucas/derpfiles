{ config, options, lib, pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      git_branch = {
        style = "purple";
        symbol = "";
      };
    };
  };
}
