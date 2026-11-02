{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "Bubble-Card";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    tag = "v${version}";
    hash = "sha256-rDJd/EfURb3r57JwnDiW/XY9mkZ4ryg1QcKeeImcv6U=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/bubble-card.js $out/
  '';

  meta = {
    description = "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "Bubble-Card";
  };
}
