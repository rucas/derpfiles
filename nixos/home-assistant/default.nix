{ pkgs, ... }:
let
  my-cards = pkgs.callPackage ../../pkgs/my-cards { };
  auto-entities = pkgs.callPackage ../../pkgs/lovelace-auto-entities { };
  theme = pkgs.home-assistant-themes.graphite;
in
{

  imports = [
    ./automations
    ./blueprints.nix
    ./helpers.nix
    ./integrations/adaptive_lighting.nix
    ./integrations/lutron_caseta.nix
    ./integrations/notify.nix
    ./integrations/sonos.nix
    ./integrations/zigbee2mqtt.nix
    ./integrations/zwave.nix
    ./networking.nix
    ./scenes
  ];

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "airthings"
        "apple_tv"
        "aranet"
        "esphome"
        "homekit_controller"
        "lutron_caseta"
        "met"
        "radio_browser"
        "roborock"
        "sensorpush"
        "unifiprotect"
        "zwave_js"
      ];
      extraPackages = ps: with ps; [ psycopg2 ];
      customComponents = [
        pkgs.home-assistant-custom-components.adaptive_lighting
        pkgs.home-assistant-custom-components.alarmo
        # successor of the removed card-mod lovelace module; registers its own
        # frontend resource, so `card_mod:` keeps working without one here
        pkgs.home-assistant-custom-components.uix
        (pkgs.callPackage ../../pkgs/hass-browser_mod { })
        # door codes, fed from lldap by the windmill door_code_sync script
        (pkgs.callPackage ../../pkgs/lock-code-manager { })
      ];
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        button-card
        light-entity-card
        mini-graph-card
        mini-media-player
        mushroom
      ];
      config = {
        default_config = { };
        frontend.themes = "!include ${theme}/${theme.pname}.yaml";
        recorder = {
          db_url = "postgresql://@/hass";
          # Lock Code Manager keeps each user's PIN as the plaintext state of a
          # `text.<entry>_<user>_pin` entity; keep those out of history.
          exclude.entity_globs = [ "text.*_pin" ];
        };
        homeassistant = {
          allowlist_external_dirs = [
            "/etc/lutron"
            "/etc/home-assistant"
          ];
        };
        http = {
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        lovelace = {
          resources =
            map
              (name: {
                url = "/local/${name}.js";
                type = "module";
              })
              [
                "my-cards"
                "auto-entities"
                "button-card"
                "light-entity-card"
                "layout-card"
                "bubble-card"
                "mushroom"
              ];
        };
        alarmo = { };
        mqtt = { };
      };
    };
  };

  # BlueZ for the onboard adapter; home-assistant's bluetooth entry needs it
  hardware.bluetooth.enable = true;

  systemd.tmpfiles.rules = [
    "d /run/hass 0700 caddy caddy"
    "L+ /run/hass/my-cards.js - - - - ${my-cards}/my-cards.js"
    "L+ /run/hass/auto-entities.js - - - - ${auto-entities}/auto-entities.js"

    "L+ /run/hass/button-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.button-card}/button-card.js"
    "L+ /run/hass/light-entity-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.light-entity-card}/light-entity-card.js"
    "L+ /run/hass/layout-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.lovelace-layout-card}/layout-card.js"
    "L+ /run/hass/bubble-card.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.bubble-card}/bubble-card.js"
    "L+ /run/hass/mushroom.js - - - - ${pkgs.home-assistant-custom-lovelace-modules.mushroom}/mushroom.js"
  ];

  # NOTE: lutron certs in /etc
  environment.etc = {
    lutron.source = ./lutron;
  };
}
