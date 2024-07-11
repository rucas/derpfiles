{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.14.6";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-WEACdu5TLo8mxhRGVH6CSFTfngUATJqKW4i1r4Wp8P0=";
  };

  npmDepsHash = "sha256-u0BamDmxrxGWBU40xFsCk33kaJHU9NWOyG3VveEARsU=";

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

