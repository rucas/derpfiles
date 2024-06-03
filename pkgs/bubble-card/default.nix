{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "Bubble-Card";
  version = "2.0.0-rc.1";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "v${version}";
    hash = "sha256-1/vLf6dWnrHsTluwUYQyJKPB8cpnJ6NIt0n8lQ6TQGs=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/bubble-card.js $out/
  '';

  meta = with lib; {
    description =
      "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
    mainProgram = "Bubble-Card";
  };
}
