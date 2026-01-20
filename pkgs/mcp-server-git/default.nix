{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "mcp-server-git";
  version = "2026.1.14";
  format = "wheel";

  src = fetchPypi {
    pname = "mcp_server_git";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-WXLi9WmANf1qS07oltmDQJ1djR/iPiZsfTTe4+iPEdE=";
  };

  propagatedBuildInputs = with python3Packages; [
    mcp
    gitpython
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = with lib; {
    description = "MCP server for Git operations";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "mcp-server-git";
  };
}
