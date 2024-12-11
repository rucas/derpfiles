{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings.general.import =
      [ pkgs.alacritty-theme.gruvbox_material_medium_dark ];
    settings = {
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
      window.decorations = "None";
      window.option_as_alt = "OnlyLeft";
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
      keyboard.bindings = [
        {
          key = "Comma";
          mods = "Command";
          command = {
            program = "sh";
            args = [ "-c" "open ~/.config/alacritty/alacritty.toml" ];
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
          chars = "\\\\x15";
        }
        # FZF alt-c change directory widget
        {
          key = "C";
          mods = "Alt";
          chars = "\\\\x1bc";
        }
      ];
      terminal.shell = {
        program = "zsh";
        args = [ "--login" ];
      };
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
