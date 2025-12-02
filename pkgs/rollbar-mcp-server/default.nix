{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "rollbar-mcp-server";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rollbar";
    repo = "rollbar-mcp-server";
    rev = "v${version}";
    hash = "sha256-n3Tv4HpkhTnSYUFudq0Q1NJ73MFOIVTs+sOL/MjCP5U=";
  };

  npmDepsHash = "sha256-84NQFg7HgJ8Kiu8zx7C3RrfyUEYpQRNP42KTxaIO6GY=";

  meta = with lib; {
    description = "Model Context Protocol server for Rollbar error monitoring";
    homepage = "https://github.com/rollbar/rollbar-mcp-server";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "rollbar-mcp-server";
  };
}
