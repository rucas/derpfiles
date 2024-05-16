{ ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        dns = {
          all_servers = true;
          bind_hosts = [ "0.0.0.0" ];
          rewrites = [
            {
              domain = "adguard.rucaslab.com";
              answer = "192.168.1.136";
            }
            {
              domain = "home.rucaslab.com";
              answer = "192.168.1.136";
            }
            {
              domain = "mqtt.rucaslab.com";
              answer = "192.168.1.136";
            }
            {
              domain = "esphome.rucaslab.com";
              answer = "192.168.1.136";
            }
            {
              domain = "radarr.rucaslab.com";
              answer = "192.168.1.136";
            }
            {
              domain = "status.rucaslab.com";
              answer = "192.168.1.136";
            }
          ];
          bootstrap_dns =
            [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
          ratelimit = 0;
          enable_dnssec = true;
          # 50 MBs
          cache_size = 1024 * 1024 * 50;
          cache_optimistic = true;
        };
        # NOTE:https://github.com/NixOS/nixpkgs/pull/247828
        #filtering = {
        #  filters = [
        #    {
        #      enabled = true;
        #      url =
        #        "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
        #      name = "AdGuard DNS filter";
        #      id = 1;
        #    }
        #    {
        #      enabled = false;
        #      url = "https://adaway.org/hosts.txt";
        #      name = "AdAway Default Blocklist";
        #      id = 2;
        #    }
        #    {
        #      enabled = false;
        #      url = "http://sbc.io/hosts/hosts";
        #      name = "Steven Black's Hosts List";
        #      id = 3;
        #    }
        #  ];
        #};
      };
    };
  };
}
