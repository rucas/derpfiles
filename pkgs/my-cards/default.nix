{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "my-cards";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "AnthonMS";
    repo = "my-cards";
    tag = "v${version}";
    hash = "sha256-H67EA8zDGNZ9EK+w3Vgb/0NvTdqxmUL177ggS8D8Cz8=";
  };

  npmDepsHash = "sha256-ia9Z65Pvupt37otSLyj0mNFakg5Cl/huIbso4QYc1NA=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/my-cards.js $out

    runHook postInstall
  '';

  meta = {
    description = "Bundle of my custom Lovelace cards for Home Assistant. Includes: my-slider, my-slider-v2, my-button";
    homepage = "https://github.com/AnthonMS/my-cards";
    license = lib.licenses.mit;
    maintainers = [ ];
  };

}
