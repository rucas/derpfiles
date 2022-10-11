{ config, options, lib, pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
    };
  };
}
