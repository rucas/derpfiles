{ pkgs, ... }:
{
  services.home-assistant.blueprints = {
    automation = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/home-assistant/core/dev/homeassistant/components/automation/blueprints/notify_leaving_zone.yaml";
        hash = "sha256-UTBelDAaVOLNn5mYmrDL/igRQEA7lcIQl9qT0GAxaGE=";
      })
    ];

    script = [
    ];

    template = [
    ];
  };
}
