{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:

let
  cfg = config.programs.claude-code-custom;

  bundledCommands = {
    note = ./commands/note.md;
    commit = ./commands/commit.md;
    plan-to-jira = ./commands/plan-to-jira.md;
    resolve-conflicts = ./commands/resolve-conflicts.md;
    fix-ci = ./commands/fix-ci.md;
    address-review = ./commands/address-review.md;
  };

  gradleEnvHook = pkgs.writeShellApplication {
    name = "claude-gradle-sdkman-hook";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./gradlew-sdkman-hook.sh;
  };

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
      buildkite.enable = lib.mkEnableOption "buildkite MCP";
      github.enable = lib.mkEnableOption "github MCP";
      rollbar.enable = lib.mkEnableOption "rollbar MCP";
      jira.enable = lib.mkEnableOption "jira MCP";
      chronosphere.enable = lib.mkEnableOption "chronosphere MCP";
      figma.enable = lib.mkEnableOption "figma MCP";
      notion.enable = lib.mkEnableOption "notion MCP";
      playwright.enable = lib.mkEnableOption "playwright MCP";
      snowflake.enable = lib.mkEnableOption "snowflake MCP";
      nixos.enable = lib.mkEnableOption "nixos MCP";
      homeAssistant = {
        enable = lib.mkEnableOption "Home Assistant MCP";
        url = lib.mkOption {
          type = lib.types.str;
          default = "http://localhost:8123";
          description = "Home Assistant base URL";
        };
      };
    };

    lsp = {
      enable = lib.mkEnableOption "LSP tool integration for Claude Code";
      servers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "pyright"
          "typescript"
          "gopls"
          "kotlin"
          "html-css"
        ];
        description = "List of LSP plugin names to enable (e.g. [\"pyright\" \"typescript\" \"gopls\"])";
      };
    };

    safetyNet.enable = lib.mkEnableOption "cc-safety-net plugin" // {
      default = true;
    };

    gradleEnv.enable = lib.mkEnableOption "auto-bootstrap the SDKMAN env for Gradle/Kotlin Bash commands";

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default model for Claude Code (e.g. \"claude-sonnet-4-6\"). Null uses Claude's built-in default.";
    };

    # Bundled slash command toggles
    commands = {
      note.enable = lib.mkEnableOption "note slash command" // {
        default = true;
      };
      commit.enable = lib.mkEnableOption "commit slash command" // {
        default = true;
      };
      plan-to-jira.enable = lib.mkEnableOption "plan-to-jira slash command";
      resolve-conflicts.enable = lib.mkEnableOption "resolve-conflicts slash command" // {
        default = true;
      };
      fix-ci.enable = lib.mkEnableOption "fix-ci slash command";
      address-review.enable = lib.mkEnableOption "address-review slash command";
      extra = lib.mkOption {
        type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
        default = { };
        description = "Additional custom slash commands beyond the bundled ones.";
      };
    };

    memory = lib.mkOption {
      type = lib.types.lines;
      default = ''
        - **Language:** English only
        - **Style**: Prefer self-documenting code over comments
        - **Attribution:** Never add AI/Claude Code attribution (no `Co-Authored-By` trailers, no "Authored via Claude Code" lines) to commits, PRs, or Jira tickets.

        # Tool Usage Guidelines
        * **File Navigation:** When you need to find files or navigate the file system, use `fd`.

          Example: `fd "filename" .`

        * **Text Search:** When you need to search for plain text or strings within files, use `rg` (ripgrep).

          Example: `rg "pattern" --files-with-matches`

        * **Code Structural Search:** For any search that requires understanding code syntax or structure,
        use `ast-grep`. Adjust the language flag (`--lang`) as needed. Avoid using `rg` or `grep` for
        this purpose.

          *Example for TypeScript:* `ast-grep --lang ts -p '<pattern>'`
          *Example for Rust:* `ast-grep --lang rust -p '<pattern>'`

        * **File Display & Piping:** When you need to display file contents or pipe output in plain format,
        use `bat -p` instead of `cat` (which is aliased to `bat`). The `-p` flag disables line numbers for
        proper piping.

          Example: `bat -p file.txt | grep "pattern"`
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      settings = {
        theme = "dark";
        model = lib.mkIf (cfg.model != null) cfg.model;
        env = lib.mkIf cfg.lsp.enable {
          ENABLE_LSP_TOOL = "1";
        };
        enabledPlugins = lib.mkIf cfg.lsp.enable (
          builtins.listToAttrs (
            map (name: {
              name = "${name}-lsp@claude-plugins-official";
              value = true;
            }) cfg.lsp.servers
          )
        );
        hooks = lib.mkIf (cfg.safetyNet.enable || cfg.gradleEnv.enable) {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks =
                (lib.optional cfg.safetyNet.enable {
                  type = "command";
                  command = "${pkgs.cc-safety-net}/bin/cc-safety-net --claude-code";
                })
                ++ (lib.optional cfg.gradleEnv.enable {
                  type = "command";
                  command = "${gradleEnvHook}/bin/claude-gradle-sdkman-hook";
                });
            }
          ];
        };
        permissions = {
          allow = [
            "Bash(*)"
            "Read(*)"
            "Edit(*)"
            "Write(*)"
            "Glob(*)"
            "Grep(*)"
            "WebFetch(*)"
            "WebSearch(*)"
          ]
          ++ (map (name: "mcp__plugin_claude-code-home-manager_${name}") (
            builtins.filter (name: cfg.mcpServers.${name}.enable) (builtins.attrNames cfg.mcpServers)
          ));
          deny = [
            "Bash(rm -rf *)"
            "Bash(git push --force*)"
            "Bash(git reset --hard*)"
            "Bash(git checkout -- *)"
            "Bash(git clean -f*)"
          ];
        };
      };
      commands =
        (lib.filterAttrs (name: _: cfg.commands.${name}.enable) bundledCommands) // cfg.commands.extra;
      context = cfg.memory;

      mcpServers = lib.filterAttrs (n: v: v != null) {
        fetch = lib.mkIf cfg.mcpServers.fetch.enable {
          command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
        };

        git = lib.mkIf cfg.mcpServers.git.enable {
          command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
        };

        time = lib.mkIf cfg.mcpServers.time.enable {
          command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
        };

        buildkite = lib.mkIf cfg.mcpServers.buildkite.enable {
          command = "${pkgs.buildkite-mcp-server}/bin/buildkite-mcp-server";
          args = [ "stdio" ];
          env.BUILDKITE_API_TOKEN = "\${BUILDKITE_MCP_TOKEN}";
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
          command = lib.getExe (
            pkgs.writeShellScriptBin "chronomcp-wrapper" ''
              exec ${pkgs.chronosphere-mcp}/bin/chronomcp \
                --config-file ${./chronosphere-mcp-config.yaml} \
                --org-name "$CHRONOSPHERE_ORG_NAME" \
                --api-token "$CHRONOSPHERE_API_TOKEN"
            ''
          );
          env = {
            CHRONOSPHERE_ORG_NAME = "\${CHRONOSPHERE_ORG_NAME}";
            CHRONOSPHERE_API_TOKEN = "\${CHRONOSPHERE_MCP_TOKEN}";
          };
        };

        figma = lib.mkIf cfg.mcpServers.figma.enable {
          type = "http";
          url = "https://mcp.figma.com/mcp";
        };

        notion = lib.mkIf cfg.mcpServers.notion.enable {
          type = "http";
          url = "https://mcp.notion.com/mcp";
        };

        playwright = lib.mkIf cfg.mcpServers.playwright.enable {
          command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
          env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        };

        nixos = lib.mkIf cfg.mcpServers.nixos.enable {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };

        homeAssistant = lib.mkIf cfg.mcpServers.homeAssistant.enable {
          command = "${pkgs.ha-mcp}/bin/ha-mcp";
          env = {
            HOMEASSISTANT_URL = cfg.mcpServers.homeAssistant.url;
            HOMEASSISTANT_TOKEN = "\${HA_MCP_TOKEN}";
          };
        };

        snowflake = lib.mkIf cfg.mcpServers.snowflake.enable {
          command = "${pkgs.snowflake-labs-mcp}/bin/snowflake-labs-mcp";
          args = [
            "--service-config-file"
            "${./snowflake-mcp-config.yaml}"
          ];
          env = {
            SNOWFLAKE_ACCOUNT = "\${SNOWFLAKE_MCP_ACCOUNT}";
            SNOWFLAKE_USER = "\${SNOWFLAKE_MCP_USER}";
            SNOWFLAKE_PASSWORD = "\${SNOWFLAKE_MCP_PASSWORD}";
          };
        };
      };
    };

    # Session variables (only if osConfig secrets available)
    home.sessionVariables = lib.mkMerge [
      (lib.mkIf (cfg.mcpServers.buildkite.enable && getSecretPath "buildkiteMCPToken" != null) {
        BUILDKITE_MCP_TOKEN = "$(cat ${getSecretPath "buildkiteMCPToken"})";
      })
      (lib.mkIf (cfg.mcpServers.github.enable && getSecretPath "githubMCPToken" != null) {
        GITHUB_MCP_TOKEN = "$(cat ${getSecretPath "githubMCPToken"})";
      })
      (lib.mkIf (cfg.mcpServers.rollbar.enable && getSecretPath "rollbarMCPToken" != null) {
        ROLLBAR_MCP_TOKEN = "$(cat ${getSecretPath "rollbarMCPToken"})";
      })
      (lib.mkIf cfg.mcpServers.jira.enable {
        JIRA_MCP_TOKEN = lib.mkIf (
          getSecretPath "jiraMCPToken" != null
        ) "$(cat ${getSecretPath "jiraMCPToken"})";
        JIRA_MCP_URL = lib.mkIf (getSecretPath "jiraMCPUrl" != null) "$(cat ${getSecretPath "jiraMCPUrl"})";
        JIRA_MCP_USERNAME = lib.mkIf (
          getSecretPath "jiraMCPUsername" != null
        ) "$(cat ${getSecretPath "jiraMCPUsername"})";
      })
      (lib.mkIf cfg.mcpServers.chronosphere.enable {
        CHRONOSPHERE_ORG_NAME = lib.mkIf (
          getSecretPath "chronosphereMcpOrgName" != null
        ) "$(cat ${getSecretPath "chronosphereMcpOrgName"})";
        CHRONOSPHERE_MCP_TOKEN = lib.mkIf (
          getSecretPath "chronosphereMcpToken" != null
        ) "$(cat ${getSecretPath "chronosphereMcpToken"})";
      })
      (lib.mkIf (cfg.mcpServers.homeAssistant.enable && getSecretPath "homeAssistantMCPToken" != null) {
        HA_MCP_TOKEN = "$(cat ${getSecretPath "homeAssistantMCPToken"})";
      })
      (lib.mkIf cfg.mcpServers.snowflake.enable {
        SNOWFLAKE_MCP_ACCOUNT = lib.mkIf (
          getSecretPath "snowflakeMcpAccount" != null
        ) "$(cat ${getSecretPath "snowflakeMcpAccount"})";
        SNOWFLAKE_MCP_USER = lib.mkIf (
          getSecretPath "snowflakeMcpUser" != null
        ) "$(cat ${getSecretPath "snowflakeMcpUser"})";
        SNOWFLAKE_MCP_PASSWORD = lib.mkIf (
          getSecretPath "snowflakeMcpPassword" != null
        ) "$(cat ${getSecretPath "snowflakeMcpPassword"})";
      })
    ];
  };
}
