{ stdenv, fetchzip, lib, ... }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "v7.1.2";

  src = fetchzip {
    url =
      "https://github.com/koekeishiya/yabai/releases/download/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-4ZJs7Xpou0Ek0CCCjbK47Nu/XPpuTpBDU8GJz5AsaUg=";
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
