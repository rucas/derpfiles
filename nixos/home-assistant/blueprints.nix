{ pkgs, ... }:
{
  services.home-assistant.blueprints = {
    automation = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/home-assistant/core/dev/homeassistant/components/automation/blueprints/notify_leaving_zone.yaml";
        hash = "sha256-UTBelDAaVOLNn5mYmrDL/igRQEA7lcIQl9qT0GAxaGE=";
      })
      # https://gist.github.com/gregtakacs/feb34999dceeb0a2a243c47e3e6e8b42
      (pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/gregtakacs/feb34999dceeb0a2a243c47e3e6e8b42/raw/lutron_pico_5_button_actions.yaml";
        hash = "sha256-fJq3YHrm2gglBWZLK6KFevOll7dn4eHgXfaV5rZFQC8=";
      })
    ];

    script = [
    ];

    template = [
    ];
  };
}
