{
  lib,
  stdenv,
  makeWrapper,
  uv,
}:

stdenv.mkDerivation {
  pname = "mcp-server-time";
  version = "0.1.0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ uv ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${uv}/bin/uvx $out/bin/mcp-server-time \
      --add-flags "mcp-server-time"
  '';

  meta = with lib; {
    description = "MCP server for time operations (via uvx)";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "mcp-server-time";
  };
}
