{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "buildkite-mcp-server";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "buildkite";
    repo = "buildkite-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ro6GK10C1q7T4uA2W8ZWo0LTOsvma5PybTc3nRib68U=";
  };

  vendorHash = "sha256-9tmECoZ+nCQGP7fBa/U5xLY0Yhwu2fdjrQ3qko+JDfU=";

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
