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
        "mqtt.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :1883
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
        "status.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :3001
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

        "ntfy.rucaslab.com" = {
          extraConfig = ''
            reverse_proxy :1234
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
