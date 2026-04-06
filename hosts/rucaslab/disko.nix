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
          hass = {
            type = "zfs_fs";
            mountpoint = "/var/lib/hass";
            options."com.sun:auto-snapshot" = "true";
          };
          prometheus2 = {
            type = "zfs_fs";
            mountpoint = "/var/lib/prometheus2";
            options."com.sun:auto-snapshot" = "true";
          };
          adguardhome = {
            type = "zfs_fs";
            mountpoint = "/var/lib/AdGuardHome";
            options."com.sun:auto-snapshot" = "true";
          };
          postgresql = {
            type = "zfs_fs";
            mountpoint = "/data/postgresql/14";
            options = {
              "com.sun:auto-snapshot" = "true";
              recordsize = "8K";
              primarycache = "metadata";
              logbias = "throughput";
            };
          };
          grafana = {
            type = "zfs_fs";
            mountpoint = "/data/grafana";
            options."com.sun:auto-snapshot" = "true";
          };
          loki = {
            type = "zfs_fs";
            mountpoint = "/data/loki";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
