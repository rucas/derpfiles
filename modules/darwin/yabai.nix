{ pkgs, ... }: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    package = pkgs.yabai;
    config = {
      mouse_follows_focus = "on";
      focus_follows_mouse = "autoraise";
      layout = "bsp";
      window_placement = "first_child";
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 6;
    };
    extraConfig = ''
      yabai -m rule --add app=".*" sub-layer=normal
      yabai -m signal --add event=application_front_switched action="yabai -m window --sub-layer normal"
      yabai -m rule --add app='System Preferences' manage=off
      yabai -m rule --add app='Cisco AnyConnect Secure Mobility Client' manage=off
    '';
  };
}
