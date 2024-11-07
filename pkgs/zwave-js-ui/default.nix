{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.26.0";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-i9DUx1rpck89CrCf1kH767lUkQU+F3YJjXAacvqi5AY=";
  };

  npmDepsHash = "sha256-o/bnFrGoU0qvbA504YJUhm5CHFNGVB6mS4KXTeYSbD0=";

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

