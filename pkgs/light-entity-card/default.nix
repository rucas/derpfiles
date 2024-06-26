{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "light-entity-card";
  version = "6.1.3";

  src = fetchFromGitHub {
    owner = "ljmerza";
    repo = "light-entity-card";
    rev = version;
    hash = "sha256-DtpNKcnxMWbKwfIwo9R2g2Vux9oAjTI0URixGC41qeA=";
  };

  npmDepsHash = "sha256-EZDTWtn3joikwiC5Kfn94+tXRDpBhMDHqHozfIkfbJ0=";

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/light-entity-card.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Control any light or switch entity";
    homepage = "https://github.com/ljmerza/light-entity-card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
