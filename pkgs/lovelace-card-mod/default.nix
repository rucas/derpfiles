{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "lovelave-card-mod";
  version = "v3.4.3";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-LFKOTu0SBeHpf8Hjvsgc/xOUux9d4lBCshdD9u7eO5o=";
  };

  npmDepsHash = "sha256-JJexFmVbDHi2JCiCpcDupzVf0xfwy+vqWILq/dLVcBo=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 card-mod.js $out

    runHook postInstall
  '';
  meta = with lib; {
    description =
      "Card Mode - Allows you to apply CSS styles to various elements of the Home Assistant frontend.";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };

}
