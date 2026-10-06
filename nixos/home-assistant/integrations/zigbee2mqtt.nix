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
        adapter = "ember";
        baudrate = 460800;
        rtscts = true;
      };
      frontend = true;
      availability = {
        enabled = true;
        passive.timeout = 180;
      };
      device_options.retain = true;
      advanced = {
        channel = 25;
        # Nix has no hex literals, so pan_id 0x1a62 is decimal. ext_pan_id is the
        # LITTLE-ENDIAN wire order of ext PAN ID 00:12:4b:00:2a:2e:40:82 -- the
        # ember driver compares it against the raw bytes from
        # ezspGetNetworkParameters, whereas zstack compared big-endian NIB bytes.
        # Reversing this makes ember leave the network and form a new one.
        pan_id = 6754;
        ext_pan_id = [
          130
          64
          46
          42
          0
          75
          18
          0
        ];
        last_seen = "ISO_8601";
        network_key = "!secret.yaml network_key";
        transmit_power = 20;
      };
    };
  };

  users.users.zigbee2mqtt.extraGroups = [ "dialout" ];
}
