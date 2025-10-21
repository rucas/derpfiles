{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "firefox-bin";
  version = "144.0";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r Firefox.app "$out/Applications/Firefox.app"
  '';

  src = fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
    sha256 = "sha256-HkRLgJIbyZnVbAWn3swer4jAKXysW5BBYpmvLHf17Mk=";
  };

  meta = with lib; {
    description = "Mozilla Firefox (binary distribution)";
    homepage = "https://www.mozilla.org/firefox/";
    platforms = platforms.darwin;
  };
}
