{
  lib,
  buildNpmPackage,
  fetchzip,
}:
buildNpmPackage (finalAttrs: {
  pname = "claude-code";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
    hash = "sha256-6BLpBNqNR2qrKBcXINqvfl2dgaQA6NmxsEsk1ILqeT8=";
    version = "2.0.58";
  };

  npmDepsHash = "sha256-XOIuOQUJ0HB86pwuUnrv0B121lO9em9XG1DAK0/L4js=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  env.AUTHORIZED = "1";

  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --unset DEV
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = lib.licenses.unfree;
    maintainers = [ ];
    mainProgram = "claude";
  };
})
