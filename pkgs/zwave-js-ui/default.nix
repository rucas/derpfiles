{ lib, buildNpmPackage, fetchFromGitHub, nixosTests }:

buildNpmPackage rec {

  pname = "zwave-js-ui";
  version = "v9.29.0";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = pname;
    rev = version;
    hash = "sha256-I3kUTObu1cRL14F8p3oia6GuPAOWMywmPJCx/nPQ0VQ=";
  };

  npmDepsHash = "sha256-fBwwQSf2AMAN28RWlLtZhosSltByydqULmDyr5WMgPg=";

  #npmBuildScript = "build:server";

  buildPhase = ''
    runHook preBuild

    npm run build:server && npm run build:ui

    runHook postBuild
  '';

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

