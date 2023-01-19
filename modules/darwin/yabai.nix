{ pkgs, ... }: {
  services.yabai.enable = true;
  services.yabai.enableScriptingAddition = true;
  services.yabai.package = pkgs.yabai;
  services.yabai.config = {
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
}
