{
  lib,
  python3Packages,
  fetchPypi,
}:
with python3Packages;
let
  openapi-pydantic = buildPythonPackage rec {
    pname = "openapi-pydantic";
    version = "0.5.1";
    format = "wheel";
    src = fetchPypi {
      pname = "openapi_pydantic";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-o6Ce9FhvW9dgqN9/QwKLYMr7bZ9h3irLqVdHZiVasUY=";
    };
    propagatedBuildInputs = [ pydantic ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  py-key-value-aio = buildPythonPackage rec {
    pname = "py-key-value-aio";
    version = "0.4.4";
    format = "wheel";
    src = fetchPypi {
      pname = "py_key_value_aio";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-GOF1ZOyuYbmH+Qn8LNQe4gEshLSx3LjAVc+LS8G/P10=";
    };
    propagatedBuildInputs = [
      beartype
      typing-extensions
      aiofile
      anyio
      keyring
      cachetools
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  valkey-no-tests = valkey.overridePythonAttrs (_old: {
    doCheck = false;
    doInstallCheck = false;
  });

  fakeredis-no-tests = fakeredis.override {
    valkey = valkey-no-tests;
    lupa = lupa-2_7;
  };

  lupa-2_7 = buildPythonPackage rec {
    pname = "lupa";
    version = "2.7";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "cp314";
      python = "cp314";
      abi = "cp314";
      platform = "macosx_11_0_arm64";
      hash = "sha256-4dgyRSl1siUb2okaEuX8I5FR80eAL9L24iJLOt9cr0k=";
    };
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  uncalled-for = buildPythonPackage rec {
    pname = "uncalled-for";
    version = "0.3.2";
    format = "wheel";
    src = fetchPypi {
      pname = "uncalled_for";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-D/YLFCx9H4BwvenUKvqnCu3HfcwQmYwidofpwVcTQY4=";
    };
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  fastmcp-3 = buildPythonPackage rec {
    pname = "fastmcp";
    version = "3.2.4";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-5snEKRcQQUVeR6uUuz+DxGV2IqDsKJIvaUAFOVm9WKk=";
    };
    propagatedBuildInputs = [
      authlib
      cyclopts
      exceptiongroup
      griffelib
      httpx
      jsonref
      jsonschema-path
      mcp
      openapi-pydantic
      opentelemetry-api
      packaging
      platformdirs
      py-key-value-aio
      pydantic
      email-validator
      pyperclip
      python-dotenv
      pyyaml
      rich
      uncalled-for
      uvicorn
      watchfiles
      websockets
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  cattrs-26 = buildPythonPackage rec {
    pname = "cattrs";
    version = "26.1.0";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-0eCATEJjlJTUadCNTybWud6birJrRG23tfjC6X98MJY=";
    };
    propagatedBuildInputs = [
      attrs
      typing-extensions
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  markdown-to-confluence = buildPythonPackage rec {
    pname = "markdown-to-confluence";
    version = "0.6.1";
    format = "wheel";
    src = fetchPypi {
      pname = "markdown_to_confluence";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-7asQs9lOSEQnM7L+xHhHNev7HbF0g0vVm7R0D/G+szE=";
    };
    propagatedBuildInputs = [
      cattrs-26
      lxml
      markdown
      orjson
      pymdown-extensions
      pyyaml
      requests
      truststore
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  rapidfuzz-wheel = buildPythonPackage rec {
    pname = "rapidfuzz";
    version = "3.14.3";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "cp314";
      python = "cp314";
      abi = "cp314";
      platform = "macosx_11_0_arm64";
      hash = "sha256-HsDIwMPU+XztRrLhkeiD+Mgtu/bV68GEI2bX7/E81aY=";
    };
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  thefuzz-custom = buildPythonPackage rec {
    pname = "thefuzz";
    version = "0.22.1";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-WXKbM1VoULkOEJPEz55hivby5MmF3xk/3zxbXPAspIE=";
    };
    propagatedBuildInputs = [
      rapidfuzz-wheel
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };
in
buildPythonApplication rec {
  pname = "mcp-atlassian";
  version = "0.23.0";
  format = "wheel";

  src = fetchPypi {
    pname = "mcp_atlassian";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-7MsazUVy368zKy2ochTM8uUnwBxjDl4mETeCPqtz1Pc=";
  };

  propagatedBuildInputs = [
    atlassian-python-api
    requests
    beautifulsoup4
    httpx
    mcp
    fastmcp-3
    python-dotenv
    markdownify
    markdown
    markdown-to-confluence
    pydantic
    trio
    click
    uvicorn
    starlette
    thefuzz-custom
    python-dateutil
    keyring
    cachetools
    fakeredis-no-tests
    truststore
    unidecode
    urllib3
    anyio
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = {
    description = "MCP server for Atlassian products (Jira and Confluence)";
    homepage = "https://github.com/sooperset/mcp-atlassian";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
