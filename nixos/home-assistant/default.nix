{ CONF, config, pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 8123 ];
  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "lutron_caseta"
        "met"
        "radio_browser"
        # "nest"
        # "unifiprotect"
      ];
      customComponents = [
        (pkgs.callPackage ../../pkgs/alarmo { })
        (pkgs.callPackage ../../pkgs/home-assistant-petkit {
          petkitaio =
            (pkgs.python311Packages.callPackage ../../pkgs/petkitaio { });
        })
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
        alarmo = { };
        "scene manual" = [
          {
            name = "TV";
            entities = { };
          }
          {
            name = "Arrive";
            entities = { };
          }
          {
            name = "Leave";
            entities = { "light.master_bedroom_main_lights" = "off"; };
          }
        ];
      };
    };
  };
  environment.etc = { lutron.source = ./lutron; };
}
