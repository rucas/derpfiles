{ config, options, lib, pkgs, ... }: {
  #idk = theme.theme.colors.primary.background;
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
      map-syntax = [
        "**/.zfuncs/*:Bourne Again Shell (bash)"
        "**/workplace/**/**/Config:Perl"
        "**/workplace/**/packageInfo:Perl"
      ];
    };
  };
}
