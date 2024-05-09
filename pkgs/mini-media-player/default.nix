{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "mini-media-player";
  version = "v1.16.9";

  src = fetchFromGitHub {
    owner = "kalkih";
    repo = "mini-media-player";
    rev = version;
    hash = "sha256-tEG8xmqsPDssXmsCobHJoNK3qdRvBRe6FcTfm16r6+g=";
  };

  npmDepsHash = "sha256-pN6Hq0ECnmSZgKPoSfdAQsqNykUakLqRCTyLGVK57KQ=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/mini-media-player-bundle.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Minimalistic media card for Home Assistant Lovelace UI";
    homepage = "https://github.com/kalkih/mini-media-player";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
