{ ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      cursor_shape = "beam";
      font_size = 12;
      font_family = "Hack Nerd Font";
      bold_font = "Hack Nerd Font Bold";
      italic_font = "Hack Nerd Font Italic";
      bold_italic_font = "Hack Nerd Font Bold Italic";
      window_padding_width = 45;
      hide_window_decorations = "yes";
      macos_thicken_font = "0.6";
    };
    theme = "Gruvbox Material Dark Medium";
  };
}
