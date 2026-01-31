{ CONF, ... }:
{
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt = {
        user = "!secret.yaml user";
        password = "!secret.yaml password";
      };
      serial = {
        port = CONF.hosts.rucaslab.zigbee.device;
        adapter = "zstack";
      };
      frontend = true;
      advanced = {
        channel = 25;
        network_key = "!secret.yaml network_key";
        transmit_power = 20;
      };
    };
  };

  users.users.zigbee2mqtt.extraGroups = [ "dialout" ];
}
