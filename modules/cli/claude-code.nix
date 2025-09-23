{ pkgs, inputs, ... }:
let
  mcpConfig = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      fetch.enable = true;
      git.enable = true;
    };
  };
in
{
  home.packages = with pkgs; [
    claude-code
    mcp-server-fetch
    mcp-server-git
    github-mcp-server
  ];

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
