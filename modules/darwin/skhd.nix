{ pkgs, ... }: {
  services.skhd.enable = true;
  services.skhd.package = pkgs.skhd;
  services.skhd.skhdConfig = ''
    # focus window
    alt - h : yabai -m window --focus west
    alt - j : yabai -m window --focus south
    alt - k : yabai -m window --focus north
    alt - l : yabai -m window --focus east

    # swap managed window
    shift + alt - h : yabai -m window --swap west
    shift + alt - j : yabai -m window --swap south
    shift + alt - k : yabai -m window --swap north
    shift + alt - l : yabai -m window --swap east

    # move managed window
    shift + cmd - h : yabai -m window --warp west
    shift + cmd - j : yabai -m window --warp south
    shift + cmd - k : yabai -m window --warp north
    shift + cmd - l : yabai -m window --warp east

    # toggle window zoom
    alt - d : yabai -m window --toggle zoom-parent
    alt - f : yabai -m window --toggle zoom-fullscreen

    # reload skhd and yabai
    ctrl + cmd - r: pkill yabai && ${pkgs.skhd}/bin/skhd -r
    ctrl + cmd - t: open -na ~/Applications/Home\ Manager\ Apps/Alacritty.app
    ctrl + cmd - c: open -na /Applications/Google\ Chrome.app

    # i3 madness
    ctrl + cmd - h : yabai -m window west --resize right:-20:0 2> /dev/null || yabai -m window --resize right:-20:0
    ctrl + cmd - j : yabai -m window north --resize bottom:0:20 2> /dev/null || yabai -m window --resize bottom:0:20
    ctrl + cmd - k : yabai -m window south --resize top:0:-20 2> /dev/null || yabai -m window --resize top:0:-20
    ctrl + cmd - l : yabai -m window east --resize left:20:0 2> /dev/null || yabai -m window --resize left:20:0
  '';
}
