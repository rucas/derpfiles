{ config, ... }:
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      homeAssistantMCPToken = {
        reference = "op://Homelab/Home Assistant MCP Token/credential";
        path = "/var/opnix/secrets/ha/token";
        owner = "lucas";
        mode = "0600";
      };
    };
  };
}
