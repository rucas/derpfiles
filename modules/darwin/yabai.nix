{ config, options, lib, pkgs, inputs, ... }: {
  services.yabai.enable = true;
  services.yabai.enableScriptingAddition = false;
  services.yabai.package = pkgs.yabai;
  services.yabai.config = {
    mouse_follows_focus = "on";
    focus_follows_mouse = "autoraise";
    layout = "float";
  };
}
