{ config, ... }: {
  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare_dynamicdns.path;
    domains = [ "portal.rucaslab.com" ];
  };
}
