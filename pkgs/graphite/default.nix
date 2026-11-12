{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "graphite";
  version = "2.7.6";

  src = fetchFromGitHub {
    owner = "TilmanGriesel";
    repo = "graphite";
    tag = version;
    hash = "sha256-BMti57/RJPcGPoMIBKe6L+J9PoP47Npv9az3NaQJkq0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp themes/graphite.yaml $out/${pname}.yaml
  '';
}
