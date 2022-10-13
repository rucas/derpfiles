{ config, options, lib, pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
      map-syntax = "**/.zfuncs/*:Bourne Again Shell (bash)";
    };
  };
}
