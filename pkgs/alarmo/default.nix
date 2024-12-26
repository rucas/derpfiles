{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "nielsfaber";
  domain = "alarmo";
  version = "1.10.7";

  src = fetchFromGitHub {
    owner = owner;
    repo = "alarmo";
    rev = "refs/tags/v${version}";
    hash = "sha256-EFR8GveMNpwhrIA0nP+Ny3YUTHAOFw+IF72hH1+wMSM=";
  };
}
