{ config, ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/papra 0750 papra papra -"
  ];

  services.papra = {
    enable = true;
    environmentFile = config.age.secrets.papra_env.path;
    environment = {
      APP_BASE_URL = "https://docs.rucaslab.com";
      PORT = 1221;
      AUTH_IS_REGISTRATION_ENABLED = false;
      INTAKE_EMAILS_IS_ENABLED = true;
      INTAKE_EMAILS_DRIVER = "catch-all";
      INTAKE_EMAILS_CATCH_ALL_DOMAIN = "docs.rucaslab.com";
    };
  };

  services.caddy.virtualHosts."docs.rucaslab.com" = {
    extraConfig = ''
      import https-proxy :1221
    '';
  };

  services.caddy.virtualHosts."http://webhook.rucaslab.com:8880" = {
    extraConfig = ''
      route /api/intake-emails/ingest {
        reverse_proxy :1221
      }
      respond 404
    '';
  };

  services.cloudflared.tunnels."87bf0875-3104-4d3a-9003-348f6fdbf14a".ingress = {
    "webhook.rucaslab.com" = {
      service = "http://localhost:8880";
    };
  };
}
