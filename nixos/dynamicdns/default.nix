{ config, ... }: {
  services.cfdyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare_dynamicdns.path;
    records = [ "portal.rucaslab.com" ];
  };
}
