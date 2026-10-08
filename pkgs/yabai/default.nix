{
  stdenv,
  fetchzip,
  lib,
  ...
}:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "7.1.25";

  src = fetchzip {
    url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/${pname}-v${version}.tar.gz";
    hash = "sha256-hGZLoY5zZjtVtjMbYQ4VHqAuAD835Tdfq6YX122/9Ik=";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
  '';

  meta = {
    description = ''
      A tiling window manager for macOS based on binary space partitioning
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    platforms = lib.platforms.darwin;
  };
}
