{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "nielsfaber";
  domain = "alarmo";
  version = "1.10.4";

  src = fetchFromGitHub {
    owner = owner;
    repo = "alarmo";
    rev = "refs/tags/v${version}";
    hash = "sha256-/hNzGPckLHUX0mrBF3ugAXstrOc1mWdati+nRJCwldc=";
  };
}
