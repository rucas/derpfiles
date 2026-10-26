{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "lovelace-layout-card";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-layout-card";
    tag = "v${version}";
    hash = "sha256-xni9cTgv5rdpr+Oo4Zh/d/2ERMiqDiTFGAiXEnigqjc=";
  };

  npmDepsHash = "sha256-Nmi51kCj/e9A0PmO/DIvOplgBnQzIEmCbuM5HjmdKGw=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 layout-card.js $out

    runHook postInstall
  '';
  meta = {
    description = "Get more control over the placement of lovelace cards.";
    homepage = "https://github.com/thomasloven/lovelace-layout-card";
    license = lib.licenses.mit;
    maintainers = [ ];
  };

}
