{
  lib,
  buildGoLatestModule,
  fetchFromGitHub,
}:

# Upstream's go.mod tracks the newest Go release, ahead of nixpkgs' default.
buildGoLatestModule (finalAttrs: {
  pname = "buildkite-mcp-server";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "buildkite";
    repo = "buildkite-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tXwEY44s2RiOS7CEiTmzFYMoBzyGA3oJLwgZdIxM+Pg=";
  };

  vendorHash = "sha256-wTGm8ME+0CLn91HSJMesRXDlIFTlRDgeGRt0JYj0uKA=";

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
