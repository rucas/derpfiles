{ config, ... }: {
  services = {
    uptime-kuma = { enable = true; };
    caddy = {
      virtualHosts = {
        "status.rucaslab.com" = {
          extraConfig =
            "import https-proxy :${config.services.uptime-kuma.settings.PORT}";
        };
      };
    };
  };
}
