{ config, ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/outline 0750 outline outline -"
    "d /var/lib/outline/data 0750 outline outline -"
  ];

  services = {
    outline = {
      enable = true;
      port = 3040;
      publicUrl = "https://wiki.rucaslab.com";
      forceHttps = false;
      databaseUrl = "postgresql://localhost/outline?host=/run/postgresql&sslmode=disable";
      redisUrl = "local";
      storage = {
        storageType = "local";
        localRootDir = "/var/lib/outline/data";
      };
      oidcAuthentication = {
        displayName = "Authelia";
        clientId = "outline";
        clientSecretFile = config.age.secrets.outline_oidc_client_secret.path;
        authUrl = "https://auth.rucaslab.com/api/oidc/authorization";
        tokenUrl = "https://auth.rucaslab.com/api/oidc/token";
        userinfoUrl = "https://auth.rucaslab.com/api/oidc/userinfo";
        scopes = [
          "openid"
          "profile"
          "email"
        ];
        usernameClaim = "preferred_username";
      };
    };
    caddy.virtualHosts."wiki.rucaslab.com" = {
      extraConfig = ''
        import https-proxy :3040
      '';
    };
  };
}
