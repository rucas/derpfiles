{ config, options, lib, pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "0x282828";
          foreground = "0xd4be98";
        };
        normal = {
          black = "0x3c3836";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
        bright = {
          black = "0x3c3836";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
      };
      cursor = {
        style = {
          shape = "Underline";
          blinking = "On";
        };
        vi_mode_style = "Block";
      };
      window.padding = {
        x = 45;
        y = 45;
      };
      use_thin_strokes = true;
      window.dynamic_title = true;
      window.decorations = "none";
      font = {
        normal = {
          family = "Hack Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "Hack Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "Hack Nerd Font";
          style = "Italic";
        };
        size = 12;
      };
      mouse.hide_when_typing = true;
    };
  };
}