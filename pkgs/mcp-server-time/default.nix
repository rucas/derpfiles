{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "mcp-server-time";
  version = "2025.9.25";
  format = "wheel";

  src = fetchPypi {
    pname = "mcp_server_time";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-XMVZcJiH2zO/d1RsLvsKk1LBOHDMK/rv+rGmvWOQQZs=";
  };

  propagatedBuildInputs = with python3Packages; [
    mcp
    tzlocal
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = with lib; {
    description = "MCP server for time operations";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "mcp-server-time";
  };
}
