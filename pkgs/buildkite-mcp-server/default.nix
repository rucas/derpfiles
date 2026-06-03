{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "buildkite-mcp-server";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "buildkite";
    repo = "buildkite-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7wi5lMckfsWiSM2JwofK5hzv92gc6LHmAW05pX92lBY=";
  };

  vendorHash = "sha256-RMBlpwTO90oB9HBRfDnRLgPuyyYXnvhv74Tk4xog5pw=";

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
