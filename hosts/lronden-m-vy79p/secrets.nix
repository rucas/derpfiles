{ config, ... }:
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      githubMCPToken = {
        reference = "op://Hermes/Github MCP Token/credential";
        path = "/usr/local/var/opnix/secrets/gh/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      jiraMCPToken = {
        reference = "op://Hermes/Jira MCP/credential";
        path = "/usr/local/var/opnix/secrets/jira/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      jiraMCPUrl = {
        reference = "op://Hermes/Jira MCP/URL";
        path = "/usr/local/var/opnix/secrets/jira/url";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      jiraMCPUsername = {
        reference = "op://Hermes/Jira MCP/Username";
        path = "/usr/local/var/opnix/secrets/jira/username";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      rollbarMCPToken = {
        reference = "op://Hermes/Rollbar MCP Token/credential";
        path = "/usr/local/var/opnix/secrets/rollbar/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      chronosphereMcpOrgName = {
        reference = "op://Hermes/Chronosphere MCP/organization";
        path = "/usr/local/var/opnix/secrets/chronosphere/organization";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };

      chronosphereMcpToken = {
        reference = "op://Hermes/Chronosphere MCP/credential";
        path = "/usr/local/var/opnix/secrets/chronosphere/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };
    };
  };
}
