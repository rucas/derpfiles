{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs,
  playwright-driver,
  playwright-mcp,
}:

buildNpmPackage {
  pname = "playwright-mcp";
  version = "unstable";

  src = playwright-mcp;

  npmDepsHash = "sha256-4YqQnNNefBIG4fiGvqpUU4LgT9L/xgJ+ji3SNr1/W78=";

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/playwright-mcp \
      --add-flags "$out/lib/node_modules/playwright-mcp-internal/packages/playwright-mcp/cli.js" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"
  '';

  meta = with lib; {
    description = "Playwright MCP server for browser automation";
    homepage = "https://github.com/microsoft/playwright-mcp";
    license = licenses.asl20;
    mainProgram = "playwright-mcp";
  };
}
