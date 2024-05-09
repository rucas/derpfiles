{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "button-card";
  version = "v4.1.2";

  src = fetchurl {
    url =
      "https://github.com/custom-cards/button-card/releases/download/${version}/button-card.js";
    hash = "sha256-HZ/meltJqJt5CZKaQf84tEZOwSRvEFOiawJ/FdZWfLo=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -D $src $out/button-card.js
  '';

  meta = with lib; {
    changelog =
      "https://github.com/custom-cards/button-card/releases/tag/v${version}";
    description = "Button Card - Lovelace button-card for home assistant";
    homepage = "https://github.com/custom-cards/button-card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };
}
