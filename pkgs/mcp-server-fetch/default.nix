{
  lib,
  stdenv,
  makeWrapper,
  uv,
}:

stdenv.mkDerivation {
  pname = "mcp-server-fetch";
  version = "0.1.0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ uv ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${uv}/bin/uvx $out/bin/mcp-server-fetch \
      --add-flags "mcp-server-fetch"
  '';

  meta = with lib; {
    description = "MCP server for fetching web content (via uvx)";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "mcp-server-fetch";
  };
}
