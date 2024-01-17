{ ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 80 443 3000 ];
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
          #upstream_dns = [
          #  "https://dns10.quad9.net/dns-query"
          #  "[/ruc.as/]192.168.1.136:53"
          #];
          #rewrites = [{
          #  domain = "adguard.ruc.as";
          #  answer = "192.168.1.136";
          #}];
          #resolve_clients = true;
          bootstrap_dns =
            [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
          ratelimit = 0;
          enable_dnssec = true;
          # 50 MBs
          cache_size = 1024 * 1024 * 50;
          cache_optimistic = true;
        };
      };
    };
  };
}
