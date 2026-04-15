{ config, pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/papra 0750 papra papra -"
    "d /var/lib/scanner 0755 root scanner -"
    "d /var/lib/scanner/org_ztdr3a6ccsh5jzv4m1gbp047 0775 scanner scanner -"
    "L /var/lib/papra/ingestion - - - - /var/lib/scanner"
  ];

  users.users.scanner = {
    isSystemUser = true;
    group = "scanner";
    home = "/var/lib/scanner";
    shell = "/bin/sh";
    hashedPasswordFile = config.age.secrets.scanner_password.path;
  };

  users.groups.scanner.members = [ "papra" ];

  systemd.services.papra.serviceConfig.WorkingDirectory = "/var/lib/papra";

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
      INGESTION_FOLDER_IS_ENABLED = true;
      INGESTION_FOLDER_WATCHER_USE_POLLING = true;
      INGESTION_FOLDER_WATCHER_POLLING_INTERVAL_MS = 2000;
      INGESTION_FOLDER_POST_PROCESSING_STRATEGY = "move";
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
