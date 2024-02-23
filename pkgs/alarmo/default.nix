{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "nielsfaber";
  domain = "alarmo";
  version = "1.9.14";

  src = fetchFromGitHub {
    owner = owner;
    repo = "alarmo";
    rev = "refs/tags/v${version}";
    hash = "sha256-rMRcctvYaMvGaeAVIUJSfrbspJy2I+DVrOniCTyl1WU=";
  };
}
