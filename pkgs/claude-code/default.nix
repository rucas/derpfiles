{
  lib,
  stdenv,
  fetchurl,
  nodejs_20,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "claude-code";
  version = "2.0.14";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-OKEBzHtxuiRtlRuIa/Bbo5Sa0/77DJjNCw1Ekw4tchk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@anthropic-ai/claude-code
    cp -r . $out/lib/node_modules/@anthropic-ai/claude-code/

    mkdir -p $out/bin
    makeWrapper ${nodejs_20}/bin/node $out/bin/claude \
      --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
      --set CLAUDE_DISABLE_AUTO_UPDATE 1 \
      --unset CLAUDE_DEV

    runHook postInstall
  '';

  meta = with lib; {
    description = "An agentic coding tool that lives in your terminal";
    longDescription = ''
      Claude Code understands your codebase and helps you code faster by executing
      routine tasks, explaining complex code, and handling git workflows - all through
      natural language commands.
    '';
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "claude";
  };
}
