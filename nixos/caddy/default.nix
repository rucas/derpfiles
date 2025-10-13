{ pkgs, config, ... }:
{
  services = {
    caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-XwZ0Hkeh2FpQL/fInaSq+/3rCLmQRVvwBM0Y1G1FZNU=";
      };
      extraConfig = ''
        (https-proxy) {
          reverse_proxy {args[:]}
          encode zstd gzip
          tls {
            dns cloudflare {$CLOUDFLARE_API_TOKEN}
          }
        }
      '';
      virtualHosts = {
        "home.rucaslab.com" = {
          extraConfig = ''
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
            handle_path /local* {
              root * /run/hass/
              file_server
            }
            reverse_proxy :8123
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
        "esphome.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :6052
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "radarr.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :7878
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "grafana.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :2342
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "paperless.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :28981
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "couchdb.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :5984
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "changedetection.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :5000
            encode zstd gzip
            tls {
              dns cloudflare {$CLOUDFLARE_API_TOKEN}
            }
          '';
        };
        "front.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :4321
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
