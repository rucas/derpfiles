{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "mini-graph-card";
  version = "v0.12.1";

  src = fetchFromGitHub {
    owner = "kalkih";
    repo = "mini-graph-card";
    rev = version;
    hash = "sha256-cDgfAfS4U3ihN808KPcG+jEQR+S2Q1M5SPqOkkYwYkI=";
  };

  npmDepsHash = "sha256-v+DqUAMNtDruR8E0sy7uAu3jndZUHkOw2xKtpY163R8=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/mini-graph-card-bundle.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Minimalistic graph card for Home Assistant Lovelace UI";
    homepage = "https://github.com/kalkih/mini-graph-card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
