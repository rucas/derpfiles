{ pkgs, ... }: {
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    position = "top";
    height = 26;
    title = "off";
    spaces = "on";
    clock = "on";
    power = "on";
    padding_left = 20;
    padding_right = 20;
    spacing_left = 15;
    spacing_right = 15;
    text_font = ''"Hack Nerd Font:Regular:10.0"'';
    icon_font = ''"Hack Nerd Font:Regular:10.0"'';
    background_color = "0xff282828";
    foreground_color = "0xffa8a8a8";
    power_icon_color = "0xffcd950c";
    battery_icon_color = "0xffd75f5f";
    dnd_icon_color = "0xffa8a8a8";
    clock_icon_color = "0xffa8a8a8";
    power_icon_strip = " ";
    space_icon = "•";
    space_icon_strip = "一 二 三 四 五 六 七 八 九 十";
    # NOTE: remove for yabai?
    spaces_for_all_displays = "on";
    display_separator = "on";
    # display_separator_icon = "";
    space_icon_color = "0xff458588";
    space_icon_color_secondary = "0xff78c4d4";
    space_icon_color_tertiary = "0xfffff9b0";
    clock_icon = "";
    dnd_icon = "";
    clock_format = ''"%m/%d/%y %R"'';
    right_shell = "off";
  };
}
