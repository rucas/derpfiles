{ ... }: {
  services.jankyborders = {
    enable = true;
    style = "round";
    order = "below";
    active_color = "0xFFFB4934";
    inactive_color = "0x3FFFFFFF";
    background_color = "0x00FFFFFF";
    width = 4.5;
    # blur_radius = 1.0;
    ax_focus = false;
    hidpi = true;
  };
}
