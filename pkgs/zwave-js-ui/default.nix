{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.10.3";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-U2ky/oXBlcQz1yJJWGqV5Twy/b1FsbdQdhRieobVQuA=";
  };

  npmDepsHash = "sha256-YARPcQkoKMN52AKremOWroxhs81EvswjqMdlkZxj8TU=";

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

