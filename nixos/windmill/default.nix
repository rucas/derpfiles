{ pkgs, config, ... }:
let
  workspace = "rucaslab";
in
{
  services = {
    windmill = {
      enable = true;
      serverPort = 8001;
      baseUrl = "https://windmill.rucaslab.com";
      database = {
        createLocally = true;
        name = "windmill";
        user = "windmill";
      };
    };
    caddy.virtualHosts."windmill.rucaslab.com" = {
      extraConfig = ''
        import auth
        import https-proxy :8001
      '';
    };
  };

  systemd.services.windmill-sync = {
    description = "Sync Windmill scripts from git repo";
    after = [ "windmill-server.service" ];
    requires = [ "windmill-server.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ ./scripts ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "windmill";
      Group = "windmill";
    };

    path = [ pkgs.curl ];

    script = ''
      until curl -sf http://localhost:8001/api/version > /dev/null 2>&1; do
        sleep 2
      done
      ${pkgs.windmill-sync}/bin/windmill-sync ${./scripts} http://localhost:8001 ${config.services.onepassword-secrets.secrets.windmillApiToken.path} ${workspace}
    '';
  };
}
