{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "nielsfaber";
  domain = "alarmo";
  version = "1.10.5";

  src = fetchFromGitHub {
    owner = owner;
    repo = "alarmo";
    rev = "refs/tags/v${version}";
    hash = "sha256-Wm4OlyY7ianjD9wg5f7B7VM8/ZaNb4ICR7uKI0KAa1Q=";
  };
}
