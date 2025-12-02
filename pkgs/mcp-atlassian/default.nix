{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
}:
with python3Packages; let
  openapi-pydantic = buildPythonPackage rec {
    pname = "openapi-pydantic";
    version = "0.5.1";
    src = fetchPypi {
      pname = "openapi_pydantic";
      inherit version;
      hash = "sha256-/2g1r2veekWfuT65O7krh0m3VPxuUbLxWQoZ3DAF7g0=";
    };
    pyproject = true;
    build-system = [poetry-core];
    propagatedBuildInputs = [pydantic];
    doCheck = false;
  };

  fastmcp-2_3_5 = buildPythonPackage rec {
    pname = "fastmcp";
    version = "2.3.5";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-CeEXI8ZYjYwTVi1esE1CsTuR6zL1PO93zIwO4SGy+Qc=";
    };
    pyproject = true;
    build-system = [
      hatchling
      uv-dynamic-versioning
    ];
    propagatedBuildInputs = [
      exceptiongroup
      httpx
      mcp
      openapi-pydantic
      python-dotenv
      rich
      typer
      websockets
    ];
    pythonRelaxDeps = [
      "mcp"
    ];
    doCheck = false;
  };

  markdown-to-confluence = buildPythonPackage rec {
    pname = "markdown-to-confluence";
    version = "0.3.0";
    src = fetchPypi {
      pname = "markdown_to_confluence";
      inherit version;
      hash = "sha256-CgnDujEYw9SgLVyZsFdaihQsq11OtI6JjJFcAukE/M4=";
    };
    pyproject = true;
    build-system = [setuptools];
    propagatedBuildInputs = [
      markdown
      lxml
      pymdown-extensions
      pyyaml
      requests
      types-pyyaml
      types-requests
      types-markdown
      types-lxml
    ];
    doCheck = false;
  };
in
  buildPythonApplication rec {
    pname = "mcp-atlassian";
    version = "0.11.10";

    src = fetchFromGitHub {
      owner = "sooperset";
      repo = "mcp-atlassian";
      rev = "v${version}";
      hash = "sha256-nDjIM98DsPwqbjDkVhwErBSWTR911lxa6w8NM9GrdPE=";
    };

    pyproject = true;

    build-system = [
      hatchling
      uv-dynamic-versioning
    ];

    propagatedBuildInputs = [
      atlassian-python-api
      requests
      beautifulsoup4
      httpx
      mcp
      fastmcp-2_3_5
      python-dotenv
      markdownify
      markdown
      markdown-to-confluence
      pydantic
      trio
      click
      uvicorn
      starlette
      thefuzz
      python-dateutil
      keyring
      cachetools
    ];

    pythonRelaxDeps = [
      "fastmcp"
    ];

    pythonRemoveDeps = [
      "types-python-dateutil"
      "types-cachetools"
    ];

    doCheck = false;

    meta = with lib; {
      description = "MCP server for Atlassian products (Jira and Confluence)";
      homepage = "https://github.com/sooperset/mcp-atlassian";
      license = licenses.mit;
      maintainers = [];
    };
  }
