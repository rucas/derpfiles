{ ... }:
{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0R933920X";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks-root = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
            luks-swap = {
              size = "69G";
              content = {
                type = "luks";
                name = "cryptswap";
                settings = {
                  keyFile = "/crypto_keyfile.bin";
                  allowDiscards = true;
                };
                content = {
                  type = "swap";
                };
              };
            };
          };
        };
      };
      data = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_4TB_S6BBNJ0RB00038E";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "datapool";
              };
            };
          };
        };
      };
    };

    zpool = {
      datapool = {
        type = "zpool";
        mode = "";
        mountpoint = "/data";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "true";
          acltype = "posixacl";
          xattr = "sa";
        };
        options = {
          ashift = "12";
        };

        datasets = {
          # --- Critical: irreplaceable data ---
          hass = {
            type = "zfs_fs";
            mountpoint = "/var/lib/hass";
          };
          postgresql = {
            type = "zfs_fs";
            mountpoint = "/data/postgresql/14";
            options = {
              recordsize = "8K";
              primarycache = "metadata";
              logbias = "throughput";
            };
          };
          actual = {
            type = "zfs_fs";
            mountpoint = "/var/lib/actual";
          };
          paperless = {
            type = "zfs_fs";
            mountpoint = "/var/lib/paperless";
          };
          couchdb = {
            # Obsidian Sync backend
            type = "zfs_fs";
            mountpoint = "/var/lib/couchdb";
          };
          esphome = {
            type = "zfs_fs";
            mountpoint = "/var/lib/esphome";
          };
          zigbee2mqtt = {
            type = "zfs_fs";
            mountpoint = "/var/lib/zigbee2mqtt";
          };
          zwave-js-ui = {
            type = "zfs_fs";
            mountpoint = "/var/lib/zwave-js-ui";
          };

          # --- Standard: config-heavy services ---
          adguardhome = {
            type = "zfs_fs";
            mountpoint = "/var/lib/AdGuardHome";
          };
          mosquitto = {
            type = "zfs_fs";
            mountpoint = "/var/lib/mosquitto";
          };
          uptime-kuma = {
            type = "zfs_fs";
            mountpoint = "/var/lib/uptime-kuma";
          };
          changedetection-io = {
            type = "zfs_fs";
            mountpoint = "/var/lib/changedetection-io";
          };
          ntfy-sh = {
            type = "zfs_fs";
            mountpoint = "/var/lib/ntfy-sh";
          };
          radarr = {
            type = "zfs_fs";
            mountpoint = "/var/lib/radarr";
          };
          lldap = {
            type = "zfs_fs";
            mountpoint = "/var/lib/lldap";
          };

          # --- Observability: regenerable data ---
          grafana = {
            type = "zfs_fs";
            mountpoint = "/data/grafana";
          };
          prometheus2 = {
            type = "zfs_fs";
            mountpoint = "/var/lib/prometheus2";
          };
          loki = {
            type = "zfs_fs";
            mountpoint = "/data/loki";
          };
        };
      };
    };
  };
}
