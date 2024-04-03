{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.10.1";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-FmWKvU/gt7Sz/hvPK7kV3oq9SO3ezfVIaDQ7OglkVEE=";
  };

  npmDepsHash = "sha256-wFyp7tY/eJBH8qDK7YfBGRNUA8Twh54mXqcgbmrX7vk=";

  passthru = { tests = { inherit (nixosTests) zwave-js; }; };

  meta = with lib; {
    changelog =
      "https://github.com/zwave-js/zwave-js-ui/releases/tag/${version}";
    description = "Z-Wave Control Panel and MQTT Gateway";
    license = licenses.mit;
    homepage = "https://github.com/zwave-js/zwave-js-server";
    maintainers = with maintainers; [ rucas ];
  };
}

