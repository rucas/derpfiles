{ pkgs, ... }:
let
  my-cards = pkgs.callPackage ../../pkgs/my-cards { };
  auto-entities = pkgs.callPackage ../../pkgs/lovelace-auto-entities { };
  theme = pkgs.home-assistant-themes.graphite;
in {

  imports = [
    ./automations
    ./lutron_caseta.nix
    ./networking.nix
    ./notify.nix
    ./scenes.nix
    ./sonos.nix
    ./zigbee2mqtt.nix
    ./zwave.nix
  ];

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "airthings"
        "apple_tv"
        "esphome"
        "homekit_controller"
        "lutron_caseta"
        "met"
        "radio_browser"
        "unifiprotect"
        "zwave_js"
      ];
      extraPackages = ps: with ps; [ psycopg2 ];
      customComponents = [
        pkgs.home-assistant-custom-components.alarmo
        (pkgs.callPackage ../../pkgs/hass-browser_mod { })
        (pkgs.callPackage ../../pkgs/ui { })
      ];
      customLovelaceModules =
        with pkgs.home-assistant-custom-lovelace-modules; [
          button-card
          light-entity-card
          mini-graph-card
          mini-media-player
          mushroom
        ];
      config = {
        default_config = { };
        frontend.themes = "!include ${theme}/${theme.pname}.yaml";
        recorder.db_url = "postgresql://@/hass";
        homeassistant = { allowlist_external_dirs = [ "/etc" ]; };
        http = {
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        lovelace = {
          resources = [{
            url = "/local/bubble-card.js";
            type = "module";
          }];
        };
        alarmo = { };
        mqtt = { };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/hass 0700 caddy caddy"
    "L+ /run/hass/my-cards.js - - - - ${my-cards}/my-cards.js"
    "L+ /run/hass/auto-entities.js - - - - ${auto-entities}/auto-entities.js"

    "L+ /run/hass/button-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.button-card}/button-card.js"
    "L+ /run/hass/light-entity-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.light-entity-card}/light-entity-card.js"
    "L+ /run/hass/layout-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.lovelace-layout-card}/layout-card.js"
    "L+ /run/hass/bubble-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.bubble-card}/bubble-card.js"
    "L+ /run/hass/card-mod.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.card-mod}/card-mod.js"
    "L+ /run/hass/mushroom.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.mushroom}/mushroom.js"
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

  # NOTE: lutron certs in /etc
  environment.etc = { lutron.source = ./lutron; };
}
