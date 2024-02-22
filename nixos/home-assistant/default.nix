{ CONF, config, ... }: {
  networking.firewall.allowedTCPPorts = [ 8123 ];
  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "lutron_caseta"
        "met"
        "nest"
        "radio_browser"
        "unifiprotect"
      ];
      config = {
        default_config = { };
        homeassistant = { allowlist_external_dirs = [ "/etc" ]; };
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        http = {
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        lutron_caseta = {
          host = CONF.hosts.lutron.internal_ip;
          keyfile = config.age.secrets.lutron.path;
          certfile = "/etc/lutron/client.crt";
          ca_certs = "/etc/lutron/ca.crt";
        };
      };
    };
  };
  environment.etc = { lutron.source = ./lutron; };
}
