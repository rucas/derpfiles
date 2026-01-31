{
  pkgs,
  config,
  ...
}:
let
  secretRules =
    let
      secretPath = ../../secrets + "/adguard-rules-${config.networking.hostName}.toml";
    in
    if builtins.pathExists secretPath then
      (builtins.fromTOML (builtins.readFile secretPath)).user_rules or [ ]
    else
      [ ];
in
{
  networking = {
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services = {
    caddy = {
      virtualHosts = {
        "adguard.rucaslab.com" = {
          extraConfig = "import https-proxy :3000";
        };
      };
    };
    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        querylog = {
          enabled = true;
          interval = "2160h"; # 90 days (3 months)
          size_memory = 1000;
        };
        statistics = {
          enabled = true;
          interval = "2160h"; # 90 days (3 months)
        };
        dns = {
          all_servers = true;
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = [
            "1.1.1.2"
            "1.0.0.2"
            "2606:4700:4700::1112"
            "2606:4700:4700::1002"
          ];
          upstream_dns = [
            "https://security.cloudflare-dns.com/dns-query"
            "https://dns.quad9.net/dns-query"
          ];
          ratelimit = 0;
          enable_dnssec = true;
          # 50 MBs
          cache_size = 1024 * 1024 * 50;
          cache_optimistic = true;
        };
        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt";
            name = "HaGeZi's Ultimate DNS Blocklist";
            id = 2;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts";
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
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt";
            name = "HaGeZi's Threat Intelligence Feeds DNS Blocklist";
            id = 5;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt";
            name = "💊 Dandelion Sprout's Anti-Malware List";
            id = 6;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
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
        user_rules = secretRules ++ [
          "@@||app2.cision.com^"
          "@@||api.my-ip.io^"
          "@@||ipv4.icanhazip.com^$client='192.168.1.1'"
          "@@||api.ipify.org^$client='192.168.1.1'"
        ];
      };
    };
  };
}
