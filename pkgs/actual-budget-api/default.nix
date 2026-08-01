{
  lib,
  buildNpmPackage,
  python3,
  node-gyp,
}:

# Node modules for @actual-app/api, built so the native better-sqlite3 addon is
# compiled from source against this nixpkgs node (prebuild-install cannot fetch
# in the sandbox). Exposed as $out/lib/node_modules so it can be symlinked next
# to a script as that script's node_modules (ESM ignores NODE_PATH).
buildNpmPackage {
  pname = "actual-budget-api";
  version = "0.0.0";

  src = lib.cleanSourceWith {
    src = ./.;
    filter =
      name: _type:
      let
        base = baseNameOf name;
      in
      base == "package.json" || base == "package-lock.json";
  };

  npmDepsHash = "sha256-suBnTzFpV2KJqvhyp8lWhSTSqdH01ltZwz8t6M492W0=";

  dontNpmBuild = true;

  nativeBuildInputs = [
    python3
    node-gyp
  ];

  env.npm_config_build_from_source = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp -r node_modules $out/lib/
    runHook postInstall
  '';
}
