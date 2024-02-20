{ ... }: {
  networking.firewall.allowedTCPPorts = [ 8123 ];
  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        http = {
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
      };
    };
  };
}
