{
  stdenv,
  fetchzip,
  lib,
  ...
}:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "v7.1.15";

  src = fetchzip {
    url = "https://github.com/koekeishiya/yabai/releases/download/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-mWN59BfexCmaahADzUP+B1xGQK8TNyrKOBKKJ00D7tg=";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
  '';

  meta = with lib; {
    description = ''
      A tiling window manager for macOS based on binary space partitioning
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    platforms = platforms.darwin;
  };
}
