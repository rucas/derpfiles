{ config, ... }:
{
  services = {
    actual = {
      enable = true;
      user = "actual";
      group = "actual";
      settings = {
        hostname = "127.0.0.1";
        port = 5006;
        dataDir = "/var/lib/actual-budget";
        serverFiles = "/var/lib/actual-budget/server-files";
        userFiles = "/var/lib/actual-budget/user-files";
      };
    };
    caddy.virtualHosts."budget.rucaslab.com" = {
      extraConfig = ''
        import https-proxy :5006
      '';
    };
  };

  systemd.services.actual = {
    environment = {
      ACTUAL_OPENID_DISCOVERY_URL = "https://auth.rucaslab.com/.well-known/openid-configuration";
      ACTUAL_OPENID_CLIENT_ID = "actual-budget";
      ACTUAL_OPENID_SERVER_HOSTNAME = "https://budget.rucaslab.com";
      ACTUAL_OPENID_ENFORCE = "true";
    };
    serviceConfig.EnvironmentFile = config.age.secrets.actual_budget_oidc_client_secret_env.path;
  };
}
