{ CONF, ... }: {
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt = {
        user = "!secret.yaml user";
        password = "!secret.yaml password";
      };
      serial = { port = CONF.hosts.rucaslab.zigbee.device; };
      frontend = true;
    };
  };
  networking.firewall = { allowedTCPPorts = [ 8080 ]; };
}
