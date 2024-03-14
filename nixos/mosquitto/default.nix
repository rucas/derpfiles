{ config, ... }: {
  services.mosquitto = {
    enable = true;
    listeners = [{
      users.root = {
        acl = [ "readwrite #" ];
        hashedPasswordFile = config.age.secrets.mosquitto.path;
      };
    }];
  };
  networking.firewall = { allowedTCPPorts = [ 1883 ]; };
}
