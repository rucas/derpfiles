{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "lovelace-layout-card";
  version = "v2.4.5";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-layout-card";
    rev = version;
    hash = "sha256-JqHpd3u3HT9JuAfCQW0Bg/UIQ/pzurQBp9/PFa+0/u0=";
  };

  npmDepsHash = "sha256-1Crvtux1IbdtZ5dMxhYcrCw/6IxLpNwNwUMEJpWm4HM=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 layout-card.js $out

    runHook postInstall
  '';
  meta = with lib; {
    description = "Get more control over the placement of lovelace cards.";
    homepage = "https://github.com/thomasloven/lovelace-layout-card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
