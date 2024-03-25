{ pkgs, config, ... }: {
  services = {
    caddy = {
      enable = true;
      package = pkgs.callPackage ../../pkgs/zaddy {
        plugins = [ "github.com/caddy-dns/cloudflare" ];
      };
      virtualHosts = {
        "adguard.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :3000
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "home.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :8123
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "zigbee.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :8080
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "zwave.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :8091
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
      };
    };
  };
  systemd.services.caddy = {
    serviceConfig = {
      # Required to use ports < 1024
      AmbientCapabilities = "cap_net_bind_service";
      CapabilityBoundingSet = "cap_net_bind_service";
      EnvironmentFile = config.age.secrets.cloudflare.path;
      TimeoutStartSec = "5m";
    };
  };
}
