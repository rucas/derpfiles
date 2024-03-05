{ config, ... }: {
  services.cfdyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare.path;
    records = [ "portal.rucaslab.com" ];
  };
}
