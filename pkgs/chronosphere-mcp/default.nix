{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "chronosphere-mcp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "chronosphereio";
    repo = "chronosphere-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bL+OzxarokltXxQgRSgbWTpGrAGNpbpuCWZjRref3z4=";
  };

  vendorHash = "sha256-fQTAkO6sjf3pA1WnRFubOf1EGpQBQ/ftL2yXklIVk3A=";

  subPackages = [ "mcp-server" ];

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/mcp-server $out/bin/chronomcp
  '';

  meta = {
    description = "MCP server for the Chronosphere observability platform";
    homepage = "https://github.com/chronosphereio/chronosphere-mcp";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "chronomcp";
  };
})
