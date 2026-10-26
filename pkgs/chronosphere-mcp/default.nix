{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "chronosphere-mcp";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "chronosphereio";
    repo = "chronosphere-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9wWK1+BXGXi6x1mFCyiJ1sp1DJnGfj+Urhk1pwqxJyo=";
  };

  vendorHash = "sha256-/hk6JwLDQNlMPGnLHAIyOSyxz8DBdsUX85f9Dds7SVc=";

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
