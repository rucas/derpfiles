{
  lib,
  stdenv,
  makeWrapper,
  uv,
}:

stdenv.mkDerivation {
  pname = "snowflake-labs-mcp";
  version = "1.3.5";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ uv ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${uv}/bin/uvx $out/bin/snowflake-labs-mcp \
      --add-flags "snowflake-labs-mcp"
  '';

  meta = with lib; {
    description = "MCP server for Snowflake (via uvx)";
    homepage = "https://github.com/Snowflake-Labs/mcp";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "snowflake-labs-mcp";
  };
}
