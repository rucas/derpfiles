{ CONF, config, pkgs, ... }:
let
  bubble = pkgs.callPackage ../../pkgs/bubble-card { };
  button-card = pkgs.callPackage ../../pkgs/button-card { };
  card-mod = pkgs.callPackage ../../pkgs/lovelace-card-mod { };
  my-cards = pkgs.callPackage ../../pkgs/my-cards { };
  auto-entities = pkgs.callPackage ../../pkgs/lovelace-auto-entities { };
in {
  networking.firewall = {
    allowedTCPPortRanges = [{
      from = 1400;
      to = 1500;
    }];
  };
  services = {
    home-assistant = {
      enable = true;
      extraComponents = [ "esphome" "lutron_caseta" "met" "radio_browser" ];
      extraPackages = ps: with ps; [ psycopg2 ];
      customComponents = [
        (pkgs.callPackage ../../pkgs/alarmo { })
        (pkgs.callPackage ../../pkgs/hass-browser_mod { })
        (pkgs.callPackage ../../pkgs/ui { })
      ];
      customLovelaceModules =
        with pkgs.home-assistant-custom-lovelace-modules; [
          light-entity-card
          mini-graph-card
          mini-media-player
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
        lovelace = {
          resources = [{
            url = "/local/bubble-card.js";
            type = "module";
          }];
        };
        zwave_js = { };
        alarmo = { };
        esphome = { };
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
        sonos = { media_player = { hosts = [ "192.168.1.141" ]; }; };
        apple_tv = { };
        unifiprotect = { };
        notify = [{
          name = "all_mobile";
          unique_id = "all_mobile";
          platform = "group";
          services = [{ service = "mobile_app_lucas_iphone"; }];
        }];
        "automation ui" = "!include automations.yaml";
        #"automation manual" = [{ alias = "Nightly Backup"; }];
        backup = { };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/hass 0700 caddy caddy"
    "L+ /run/hass/bubble-card.js - - - - ${bubble}/bubble-card.js"
    "L+ /run/hass/button-card.js - - - - ${button-card}/button-card.js"
    "L+ /run/hass/card-mod.js - - - - ${card-mod}/card-mod.js"
    "L+ /run/hass/my-cards.js - - - - ${my-cards}/my-cards.js"
    "L+ /run/hass/auto-entities.js - - - - ${auto-entities}/auto-entities.js"
  ];

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
    behindProxy = true;
    settings = {
      zwave = { port = CONF.hosts.rucaslab.zwave.device; };
      ui = {
        darkMode = true;
        navTabs = true;
      };
    };
    networkKeyFile = config.age.secrets.zwave-js-ui.path;
  };

  # NOTE: lutron certs in /etc
  environment.etc = { lutron.source = ./lutron; };
}
