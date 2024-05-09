{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "my-cards";
  version = "v1.0.5";

  src = fetchFromGitHub {
    owner = "AnthonMS";
    repo = "my-cards";
    rev = version;
    hash = "sha256-sPxiO+zxvUzAA/TBn1XWRyx6Kc4n59d1rRdn47pctuw=";
  };

  npmDepsHash = "sha256-QohapCm6ABarHYwLlAhubvlrU5Z626vNAX1OB8b9A6g=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/my-cards.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "Bundle of my custom Lovelace cards for Home Assistant. Includes: my-slider, my-slider-v2, my-button";
    homepage = "https://github.com/AnthonMS/my-cards";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
