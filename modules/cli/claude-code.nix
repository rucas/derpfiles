{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:

let
  cfg = config.programs.claude-code-custom;

  # Helper to safely access osConfig secrets
  getSecretPath =
    name:
    if osConfig != null && osConfig ? services.onepassword-secrets.secretPaths.${name} then
      osConfig.services.onepassword-secrets.secretPaths.${name}
    else
      null;
in
{
  options.programs.claude-code-custom = {
    enable = lib.mkEnableOption "Claude Code with MCP servers";

    # MCP server toggles
    mcpServers = {
      fetch.enable = lib.mkEnableOption "fetch MCP" // {
        default = true;
      };
      git.enable = lib.mkEnableOption "git MCP" // {
        default = true;
      };
      time.enable = lib.mkEnableOption "time MCP" // {
        default = true;
      };
      github.enable = lib.mkEnableOption "github MCP";
      rollbar.enable = lib.mkEnableOption "rollbar MCP";
      jira.enable = lib.mkEnableOption "jira MCP";
      chronosphere.enable = lib.mkEnableOption "chronosphere MCP";
    };

    # Optional: Override defaults
    memory = lib.mkOption {
      type = lib.types.lines;
      default = ''
        - **Language:** English only
        - **Style**: Prefer self-documenting code over comments

        # Tool Usage Guidelines
        *   **File Navigation:** When you need to find files or navigate the file system, use `fd`. Example: `fd "filename" .`
        *   **Text Search:** When you need to search for plain text or strings within files, use `rg` (ripgrep). Example: `rg "pattern" --files-with-matches`
        *   **Code Structural Search:** For any search that requires understanding code syntax or structure, you must default to `ast-grep`. Adjust the language flag (`--lang`) as needed. Avoid using `rg` or `grep` for this purpose.
          *   *Example for TypeScript:* `ast-grep --lang ts -p '<pattern>'`
          *   *Example for Rust:* `ast-grep --lang rust -p '<pattern>'`
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      settings = {
        theme = "dark";
        permissions.allow = [
          # Nix package manager commands
          "Bash(nix build *)"
          "Bash(nix develop *)"
          "Bash(nix eval *)"
          "Bash(nix flake check *)"
          "Bash(nix flake metadata *)"
          "Bash(nix flake show *)"
          "Bash(nix log *)"
          "Bash(nix run *)"
          "Bash(nix search *)"

          # Search and file tools
          "Bash(rg *)"
          "Bash(fd *)"
        ];
      };
      memory.text = cfg.memory;

      mcpServers = lib.filterAttrs (n: v: v != null) {
        fetch = lib.mkIf cfg.mcpServers.fetch.enable {
          command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
        };

        git = lib.mkIf cfg.mcpServers.git.enable {
          command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
          args = [
            "--repository"
            "."
          ];
        };

        time = lib.mkIf cfg.mcpServers.time.enable {
          command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
        };

        github = lib.mkIf cfg.mcpServers.github.enable {
          command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
          args = [ "stdio" ];
          env.GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_MCP_TOKEN}";
        };

        rollbar = lib.mkIf cfg.mcpServers.rollbar.enable {
          command = "${pkgs.rollbar-mcp-server}/bin/rollbar-mcp-server";
          env.ROLLBAR_ACCESS_TOKEN = "\${ROLLBAR_MCP_TOKEN}";
        };

        jira = lib.mkIf cfg.mcpServers.jira.enable {
          command = "${pkgs.mcp-atlassian}/bin/mcp-atlassian";
          env = {
            JIRA_URL = "\${JIRA_MCP_URL}";
            JIRA_USERNAME = "\${JIRA_MCP_USERNAME}";
            JIRA_API_TOKEN = "\${JIRA_MCP_TOKEN}";
          };
        };

        chronosphere = lib.mkIf cfg.mcpServers.chronosphere.enable {
          type = "http";
          url = "https://\${CHRONOSPHERE_ORG_NAME}.chronosphere.io/api/mcp/mcp";
          headers.Authorization = "\${CHRONOSPHERE_MCP_TOKEN}";
          env = {
            CHRONOSPHERE_ORG_NAME = "\${CHRONOSPHERE_ORG_NAME}";
            CHRONOSPHERE_MCP_TOKEN = "\${CHRONOSPHERE_MCP_TOKEN}";
          };
        };
      };
    };

    # Session variables (only if osConfig secrets available)
    home.sessionVariables = lib.mkMerge [
      (lib.mkIf (cfg.mcpServers.github.enable && getSecretPath "githubMCPToken" != null) {
        GITHUB_MCP_TOKEN = "$(cat ${getSecretPath "githubMCPToken"})";
      })
      (lib.mkIf (cfg.mcpServers.rollbar.enable && getSecretPath "rollbarMCPToken" != null) {
        ROLLBAR_MCP_TOKEN = "$(cat ${getSecretPath "rollbarMCPToken"})";
      })
      (lib.mkIf (cfg.mcpServers.jira.enable) {
        JIRA_MCP_TOKEN = lib.mkIf (
          getSecretPath "jiraMCPToken" != null
        ) "$(cat ${getSecretPath "jiraMCPToken"})";
        JIRA_MCP_URL = lib.mkIf (getSecretPath "jiraMCPUrl" != null) "$(cat ${getSecretPath "jiraMCPUrl"})";
        JIRA_MCP_USERNAME = lib.mkIf (
          getSecretPath "jiraMCPUsername" != null
        ) "$(cat ${getSecretPath "jiraMCPUsername"})";
      })
      (lib.mkIf (cfg.mcpServers.chronosphere.enable) {
        CHRONOSPHERE_ORG_NAME = lib.mkIf (
          getSecretPath "chronosphereMcpOrgName" != null
        ) "$(cat ${getSecretPath "chronosphereMcpOrgName"})";
        CHRONOSPHERE_MCP_TOKEN = lib.mkIf (
          getSecretPath "chronosphereMcpToken" != null
        ) "$(cat ${getSecretPath "chronosphereMcpToken"})";
      })
    ];
  };
}
