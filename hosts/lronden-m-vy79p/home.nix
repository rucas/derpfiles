{
  pkgs,
  inputs,
  osConfig,
  ...
}:
{

  imports = [
    ../../modules/cli
    ../../modules/desktop/browsers
    ../../modules/desktop/editors
    ../../modules/desktop/productivity
    ../../modules/desktop/term
    ../../modules/shell/zsh
    ../../modules/security
  ];

  programs.home-manager.enable = true;

  programs.claude-code = {
    enable = true;
    memory.text = ''
      - **Language:** English only - all code, comments, docs, examples, commits, configs, errors, tests
      - **Tools**: Use rg not grep, fd not find, tree is installed
      - **Style**: Prefer self-documenting code over comments
    '';
    mcpServers = {
      fetch = {
        command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
      };
      git = {
        command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
        args = [
          "--repository"
          "."
        ];
      };
      github = {
        command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
        args = [
          "stdio"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_MCP_TOKEN}";
        };
      };
      time = {
        command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
      };
      rollbar = {
        command = "${pkgs.rollbar-mcp-server}/bin/rollbar-mcp-server";
        env = {
          ROLLBAR_ACCESS_TOKEN = "\${ROLLBAR_MCP_TOKEN}";
        };
      };
      jira = {
        command = "${pkgs.mcp-atlassian}/bin/mcp-atlassian";
        env = {
          JIRA_URL = "\${JIRA_MCP_URL}";
          JIRA_USERNAME = "\${JIRA_MCP_USERNAME}";
          JIRA_API_TOKEN = "\${JIRA_MCP_TOKEN}";
        };
      };
      chronosphere = {
        type = "http";
        url = "https://\${CHRONOSPHERE_ORG_NAME}.chronosphere.io/api/mcp/mcp";
        headers = {
          Authorization = "\${CHRONOSPHERE_MCP_TOKEN}";
        };
        env = {
          CHRONOSPHERE_ORG_NAME = "\${CHRONOSPHERE_ORG_NAME}";
          CHRONOSPHERE_MCP_TOKEN = "\${CHRONOSPHERE_MCP_TOKEN}";
        };
      };
    };
  };

  home.sessionVariables = {
    GITHUB_MCP_TOKEN = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.githubMCPToken})";
    ROLLBAR_MCP_TOKEN = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.rollbarMCPToken})";
    JIRA_MCP_TOKEN = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.jiraMCPToken})";
    JIRA_MCP_URL = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.jiraMCPUrl})";
    JIRA_MCP_USERNAME = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.jiraMCPUsername})";
    CHRONOSPHERE_ORG_NAME = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.chronosphereMcpOrgName})";
    CHRONOSPHERE_MCP_TOKEN = "$(cat ${osConfig.services.onepassword-secrets.secretPaths.chronosphereMcpToken})";
  };

  home.username = "lucas.rondenet";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages = [
    (import ../../pkgs/dnd pkgs)
    (import ../../pkgs/shortuuid pkgs)
    inputs.nxvm.packages.${pkgs.system}.default
    inputs.opnix.packages.${pkgs.system}.default
  ];

  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";

}
