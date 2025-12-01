{
  osConfig,
  pkgs,
  inputs,
  ...
}:
let
  mcpConfig = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      fetch.enable = true;
      git.enable = true;
      github = {
        enable = true;
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_MCP_TOKEN}";
        };
      };
      time.enable = true;
    };
  };
in
{
  # NOTE:
  # this creates a ~/.claude/.mcp.json to use this:
  # claude --mcp-config ~/.claude/.mcp.json
  home.packages = (
    with pkgs;
    [
      claude-code
      mcp-server-fetch
      mcp-server-git
      github-mcp-server
    ]
  );

  home.sessionVariables = {
    GITHUB_MCP_TOKEN = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.githubMCPToken})";
  };

  xdg.configFile."../.claude/.mcp.json" = {
    text = builtins.readFile "${mcpConfig}";
    force = true;
  };

  xdg.configFile."../.claude/CLAUDE.md" = {
    text = ''
      - **Language:** English only - all code, comments, docs, examples, commits, configs, errors, tests
      - **Tools**: Use rg not grep, fd not find, tree is installed
      - **Style**: Prefer self-documenting code over comments
    '';
    force = true;
  };
}
