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
      githubMCPToken = {
        reference = "op://Homelab/GitHub MCP Token/credential";
        path = "/var/opnix/secrets/github/token";
        owner = "lucas";
        mode = "0600";
      };
      windmillApiToken = {
        reference = "op://Homelab/Windmill API Token/credential";
        path = "/var/opnix/secrets/windmill/token";
        owner = "windmill";
        mode = "0400";
      };
    };
  };
}
