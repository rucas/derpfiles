{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "buildkite-mcp-server";
  version = "1.26.1";

  src = fetchFromGitHub {
    owner = "buildkite";
    repo = "buildkite-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m2O70jgEA2Ob9JWH3grCSpDp8nXwhiSYI97P0By/Qb4=";
  };

  vendorHash = "sha256-vMu+6vJ7QM1MLEv6AtX1UDQbWhCYOSYA3H/GRsK1w44=";

  subPackages = [ "cmd/buildkite-mcp-server" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Model Context Protocol server for Buildkite CI/CD";
    homepage = "https://github.com/buildkite/buildkite-mcp-server";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "buildkite-mcp-server";
  };
})
