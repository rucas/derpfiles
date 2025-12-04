{ config, ... }:
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      githubMCPToken = {
        reference = "op://Salus/Github MCP Token/credential";
        path = "/usr/local/var/opnix/secrets/gh/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };
    };
  };
}
