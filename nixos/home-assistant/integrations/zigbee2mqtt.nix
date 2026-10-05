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
      availability = {
        enabled = true;
        passive.timeout = 180;
      };
      device_options.retain = true;
      advanced = {
        channel = 25;
        # Nix has no hex literals: 0x1a62, and ext PAN ID 00:12:4b:00:2a:2e:40:82.
        # Pinned because the ember adapter compares these strictly and re-forms
        # the network on mismatch; zstack silently tolerates the 0xDD.. default.
        pan_id = 6754;
        ext_pan_id = [
          0
          18
          75
          0
          42
          46
          64
          130
        ];
        last_seen = "ISO_8601";
        network_key = "!secret.yaml network_key";
        transmit_power = 20;
      };
    };
  };

  users.users.zigbee2mqtt.extraGroups = [ "dialout" ];
}
