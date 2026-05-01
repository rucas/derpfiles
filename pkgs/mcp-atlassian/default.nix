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

  py-key-value-shared = buildPythonPackage rec {
    pname = "py-key-value-shared";
    version = "0.3.0";
    format = "wheel";
    src = fetchPypi {
      pname = "py_key_value_shared";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-Ww77p+vKCLsVix6Tr8LwfTC49AwvwSziSkwNhPQvkpg=";
    };
    propagatedBuildInputs = [
      typing-extensions
      beartype
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  py-key-value-aio = buildPythonPackage rec {
    pname = "py-key-value-aio";
    version = "0.3.0";
    format = "wheel";
    src = fetchPypi {
      pname = "py_key_value_aio";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-HHgZFXZgeL/WCNqnaf77l+ZdHXN0aj37ZARg4yIHG2Q=";
    };
    propagatedBuildInputs = [
      py-key-value-shared
      beartype
      cachetools
      redis
      diskcache
      pathvalidate
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  valkey-no-tests = valkey.overridePythonAttrs (old: {
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
      dist = "cp313";
      python = "cp313";
      abi = "cp313";
      platform = "macosx_11_0_arm64";
      hash = "sha256-1NPNYQDa1mZJkrYDl6PQcx/85mO5Zuqg/ctc/KwmVQs=";
    };
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  pydocket = buildPythonPackage rec {
    pname = "pydocket";
    version = "0.16.3";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-4rUJJTVufNU1KGJVGVRYrHu6FfJSkzVmUbNtIj213Xw=";
    };
    propagatedBuildInputs = [
      cloudpickle
      exceptiongroup
      fakeredis-no-tests
      lupa-2_7
      opentelemetry-api
      opentelemetry-exporter-prometheus
      opentelemetry-instrumentation
      prometheus-client
      py-key-value-aio
      python-json-logger
      redis
      rich
      typer
      typing-extensions
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  fastmcp-2_14 = buildPythonPackage rec {
    pname = "fastmcp";
    version = "2.14.0";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-ezdMC8rx7x70a5JV6oTGB/NUKR6vZH/1akfGn17AwgQ=";
    };
    propagatedBuildInputs = [
      authlib
      cyclopts
      exceptiongroup
      httpx
      jsonschema-path
      mcp
      openapi-pydantic
      platformdirs
      py-key-value-aio
      pydocket
      pyperclip
      python-dotenv
      rich
      typer
      websockets
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  markdown-to-confluence = buildPythonPackage rec {
    pname = "markdown-to-confluence";
    version = "0.3.5";
    format = "wheel";
    src = fetchPypi {
      pname = "markdown_to_confluence";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-dEaXEKJdRSQoJ7IUP9sAvjxhq288rJmP1AIfJoSgG5E=";
    };
    propagatedBuildInputs = [
      markdown
      lxml
      pymdown-extensions
      pyyaml
      requests
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
      dist = "cp313";
      python = "cp313";
      abi = "cp313";
      platform = "macosx_11_0_arm64";
      hash = "sha256-FwT8cNIUKU5VSiQhtHN3m83u9xWIHF6SfcDxHhaSoP8=";
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
  version = "0.21.1";
  format = "wheel";

  src = fetchPypi {
    pname = "mcp_atlassian";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-jvn1popYrCZKpsmMiR598UoC7d5yTwasXqhpsL5gtmY=";
  };

  propagatedBuildInputs = [
    atlassian-python-api
    requests
    beautifulsoup4
    httpx
    mcp
    fastmcp-2_14
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
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = with lib; {
    description = "MCP server for Atlassian products (Jira and Confluence)";
    homepage = "https://github.com/sooperset/mcp-atlassian";
    license = licenses.mit;
    maintainers = [ ];
  };
}
