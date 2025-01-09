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
          bootstrap_dns =
            [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
          upstream_dns =
            [ "https://0ms.dev/dns-query" "https://dns10.quad9.net/dns-query" ];
          ratelimit = 0;
          enable_dnssec = true;
          # 50 MBs
          cache_size = 1024 * 1024 * 50;
          cache_optimistic = true;
        };
        filtering = {
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
        };
        filters = [
          {
            enabled = true;
            url =
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url =
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt";
            name = "HaGeZi's Ultimate DNS Blocklist";
            id = 2;
          }
          {
            enabled = true;
            url =
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts";
            name = "Steven Black's Hosts List";
            id = 3;
          }
          {
            enabled = true;
            url = "https://someonewhocares.org/hosts/hosts";
            name = "Dan Pollock Block List";
            id = 4;
          }
          {
            enabled = true;
            url =
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt";
            name = "HaGeZi's Threat Intelligence Feeds DNS Blocklist";
            id = 5;
          }
          {
            enabled = true;
            url =
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt";
            name = "💊 Dandelion Sprout's Anti-Malware List";
            id = 6;
          }
          {
            enabled = true;
            url =
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
            name = "Perflyst and Dandelion Sprout's Smart-TV Blocklist";
            id = 7;
          }
          {
            enabled = true;
            url = "https://big.oisd.nl";
            name = "oisd big block list";
            id = 8;
          }
        ];
        user_rules = [ "@@||app2.cision.com^" "@@||api.my-ip.io^" ];
      };
    };
  };
}
