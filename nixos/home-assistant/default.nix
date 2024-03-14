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
      extraPackages = ps: with ps; [ psycopg2 ];
      customComponents = [
        (pkgs.callPackage ../../pkgs/alarmo { })
        #(pkgs.callPackage ../../pkgs/home-assistant-petkit {
        #  petkitaio =
        #    (pkgs.python311Packages.callPackage ../../pkgs/petkitaio { });
        #})
      ];
      config = {
        default_config = { };
        recorder.db_url = "postgresql://@/hass";
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
        zwave_js = { };
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
        mqtt = { };
      };
    };
  };

  # NOTE: postgres for performance+historical
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensureDBOwnership = true;
    }];
  };

  services.zwave-js-ui = {
    enable = true;
    openFirewall = true;
    device = CONF.hosts.rucaslab.zwave.device;
  };

  # NOTE: lutron certs in /etc
  environment.etc = { lutron.source = ./lutron; };
}
