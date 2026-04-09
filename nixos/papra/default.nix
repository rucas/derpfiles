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
    };
  };

  services.caddy.virtualHosts."docs.rucaslab.com" = {
    extraConfig = ''
      import https-proxy :1221
    '';
  };
}
