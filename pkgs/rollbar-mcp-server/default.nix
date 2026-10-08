{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "rollbar-mcp-server";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "rollbar";
    repo = "rollbar-mcp-server";
    rev = "v${version}";
    hash = "sha256-CJPoFMhf6NHH60T7y2z965EUwIqq34BlE6RHNuPtCWI=";
  };

  npmDepsHash = "sha256-z2P5volGfxaKBY/AWeWhwCe7Nq8lQplAkYeS3Lj3geY=";

  meta = {
    description = "Model Context Protocol server for Rollbar error monitoring";
    homepage = "https://github.com/rollbar/rollbar-mcp-server";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "rollbar-mcp-server";
  };
}
