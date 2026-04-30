{ config, ... }:
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      githubMCPToken = {
        reference = "op://Homelab/Github MCP Token/credential";
        path = "/usr/local/var/opnix/secrets/gh/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };
      homeAssistantMCPToken = {
        reference = "op://Homelab/Home Assistant MCP Token/credential";
        path = "/usr/local/var/opnix/secrets/ha/token";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };
      sshOnionHost = {
        reference = "op://Homelab/SSH Onion Host/credential";
        path = "/usr/local/var/opnix/secrets/ssh/onion-host";
        owner = config.system.primaryUser;
        group = "staff";
        mode = "0600";
      };
    };
  };
}
