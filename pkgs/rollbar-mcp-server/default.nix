{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "rollbar-mcp-server";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "rollbar";
    repo = "rollbar-mcp-server";
    rev = "v${version}";
    hash = "sha256-KjreL5pi6PD6xq4aOLTvMj0i+dnshOOwBKxLcjsQVi0=";
  };

  npmDepsHash = "sha256-miY4ywc/REv80+qmpOoTzfQdLg053Ova6Z46VyJFRCI=";

  meta = {
    description = "Model Context Protocol server for Rollbar error monitoring";
    homepage = "https://github.com/rollbar/rollbar-mcp-server";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "rollbar-mcp-server";
  };
}
