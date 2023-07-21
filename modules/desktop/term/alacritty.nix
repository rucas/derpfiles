{ ... }: {
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
      # NOTE: https://github.com/alacritty/alacritty/issues/93#issuecomment-1364783147
      key_bindings = [
        {
          key = "Comma";
          mods = "Command";
          command = {
            program = "sh";
            args = [ "-c" "open ~/.config/alacritty/alacritty.yml" ];
          };
        }
        {
          key = "N";
          mods = "Command";
          action = "SpawnNewInstance";
        }
        {
          key = "Space";
          mods = "Alt";
          chars = " ";
        }
        {
          key = "Back";
          mods = "Super";
          chars = "\\x15";
        }
        # FZF alt-c change directory widget
        {
          key = "C";
          mods = "Alt";
          chars = "\\x1bc";
        }
      ];
      shell = {
        program = "zsh";
        args = [ "--login" ];
      };
      env = { TERM = "xterm-256color"; };
      #hints = {
      #  enabled = [{
      #    regex =
      #      "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)\[^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^⟨⟩`]+";
      #    command = "open";
      #    mouse = { enabled = true; };
      #  }];
      #};
    };
  };
}
