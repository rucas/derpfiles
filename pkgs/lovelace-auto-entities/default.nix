{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "lovelace-auto-entities";
  version = "v1.13.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-auto-entities";
    rev = version;
    hash = "sha256-ls8Jqt5SdiY5ROhtaSS4ZvoY+nHv6UB1RYApOJzC1VQ=";
  };

  npmDepsHash = "sha256-9z4YzLNxNh7I4yFxuPT3/erZO4itAiqyxL1a0pUTFRs=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 auto-entities.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "🔹Automatically populate the entities-list of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-auto-entities";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
