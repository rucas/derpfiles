{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "mcp-server-fetch";
  version = "2025.4.7";
  format = "wheel";

  src = fetchPypi {
    pname = "mcp_server_fetch";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-NJt5dU2dXK63w/Qn7wevKplNTJmNqzPAYOufvrnajWs=";
  };

  propagatedBuildInputs = with python3Packages; [
    mcp
    httpx
    beautifulsoup4
    readability-lxml
    readabilipy
    lxml
    trafilatura
    markdownify
    protego
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = with lib; {
    description = "MCP server for fetching web content";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "mcp-server-fetch";
  };
}
