{
  lib,
  buildNpmPackage,
  bun,
  makeWrapper,
  nodejs,
  src,
}:

buildNpmPackage {
  pname = "temporal-mcp";
  version = "0.2.1-unstable-2026-10-06";

  inherit src;

  # Upstream ships only a bun lockfile; npmDeps needs an npm one.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    chmod u+w package-lock.json
  '';

  npmDepsHash = "sha256-DvIPm00u03xGB5DiB/WiUrfMJZwJGwbUMU2R6w0Eyhw=";

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  # The repo builds through bun, not an npm script.
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild
    bun run scripts/build-javascript.ts
    runHook postBuild
  '';

  # dist/cli.js keeps its dependencies external, so they ship alongside it.
  installPhase = ''
    runHook preInstall
    npm prune --omit=dev --ignore-scripts
    mkdir -p $out/lib/temporal-mcp
    cp -r dist node_modules package.json packages $out/lib/temporal-mcp/
    makeWrapper ${lib.getExe nodejs} $out/bin/temporal-mcp \
      --add-flags $out/lib/temporal-mcp/dist/cli.js
    runHook postInstall
  '';

  meta = {
    description = "Read-only Model Context Protocol server for inspecting Temporal workflows";
    homepage = "https://github.com/stevekinney/temporal-mcp";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "temporal-mcp";
  };
}
