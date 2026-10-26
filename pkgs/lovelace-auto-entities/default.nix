{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "lovelace-auto-entities";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-auto-entities";
    tag = "v${version}";
    hash = "sha256-yMqf4LA/fBTIrrYwacUTb2fL758ZB1k471vdsHAiOj8=";
  };

  npmDepsHash = "sha256-XLhTLK08zW1BFj/PI8/61FWzoyvWi5X5sEkGlF1IuZU=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 auto-entities.js $out

    runHook postInstall
  '';

  meta = {
    description = "🔹Automatically populate the entities-list of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-auto-entities";
    license = lib.licenses.mit;
    maintainers = [ ];
  };

}
