{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "nielsfaber";
  domain = "alarmo";
  version = "1.10.3";

  src = fetchFromGitHub {
    owner = owner;
    repo = "alarmo";
    rev = "refs/tags/v${version}";
    hash = "sha256-mHmBwL1REh2UV1rT1QxZ3BpKKnPqpIPu5d5dnrWCT88=";
  };
}
