{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.9.0";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-1bgnny2PnaC5v4JhAYaiwhAsovN3qB4UQ4/H3OevDXY=";
  };

  npmDepsHash = "sha256-YfknyVipaVw2mtYFyHNC8N8TsURg4VGYF/swS7vol74=";

  # NOTE: is this actually needed?
  # npmFlags = [ "--include=dev" ];

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

