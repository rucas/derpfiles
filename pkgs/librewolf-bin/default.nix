{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "librewolf-bin";
  version = "143.0-1";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r LibreWolf.app "$out/Applications/LibreWolf.app"
  '';

  src = fetchurl {
    name = "LibreWolf-${version}.dmg";
    url = "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/${version}/librewolf-${version}-macos-arm64-package.dmg";
    sha256 = "sha256-09iHaWdU5w5oYb1HbwQ7TlbgxsZBoYvB4w9MomwFe88=";
  };

  meta = with lib; {
    description = "LibreWolf (binary distribution)";
    homepage = "https://librewolf.net/";
    platforms = platforms.darwin;
  };
}
