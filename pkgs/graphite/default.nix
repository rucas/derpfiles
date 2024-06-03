{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "graphite";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "TilmanGriesel";
    repo = "graphite";
    rev = "${version}";
    hash = "sha256-UzYg6+Mv8jkalCC68NVDbVdTrj1ZYdPC06iuFf255rw=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/graphite.yaml $out/${pname}.yaml
  '';
}
