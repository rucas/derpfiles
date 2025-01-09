{ config, ... }:
let port = 1883;
in {
  services = {
    mosquitto = {
      enable = true;
      listeners = [{
        users.root = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = config.age.secrets.mosquitto.path;
        };
      }];
    };
    caddy = {
      virtualHosts = {
        "mqtt.rucaslab.com" = {
          extraConfig = "import https-proxy :${toString port}";
        };
      };
    };
  };
  networking.firewall = { allowedTCPPorts = [ port ]; };
}
