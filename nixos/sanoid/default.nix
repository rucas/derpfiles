_:
#
# Sanoid manages local ZFS snapshot retention for all datapool datasets.
# Offsite backups are handled by restic → AWS S3 Glacier (nixos/restic).
#
# For ZFS dataset migration steps on a live system, see hosts/rucaslab/TODO.md
{
  services.sanoid = {
    enable = true;

    templates = {
      # Databases, documents, IoT configs — painful or impossible to recreate
      critical = {
        hourly = 24;
        daily = 14;
        weekly = 8;
        monthly = 6;
        autosnap = true;
        autoprune = true;
      };

      # Service state that takes effort to reconfigure
      standard = {
        hourly = 12;
        daily = 7;
        weekly = 4;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };

      # Metrics / logs — bulky, regenerable, short retention
      observability = {
        hourly = 4;
        daily = 3;
        weekly = 2;
        monthly = 1;
        autosnap = true;
        autoprune = true;
      };
    };

    datasets = {
      # Critical
      "datapool/postgresql" = {
        useTemplate = [ "critical" ];
      };
      "datapool/hass" = {
        useTemplate = [ "critical" ];
      };
      "datapool/esphome" = {
        useTemplate = [ "critical" ];
      };
      "datapool/zigbee2mqtt" = {
        useTemplate = [ "critical" ];
      };
      "datapool/zwave-js-ui" = {
        useTemplate = [ "critical" ];
      };

      # Standard
      "datapool/adguardhome" = {
        useTemplate = [ "standard" ];
      };
      "datapool/mosquitto" = {
        useTemplate = [ "standard" ];
      };
      "datapool/uptime-kuma" = {
        useTemplate = [ "standard" ];
      };
      "datapool/changedetection-io" = {
        useTemplate = [ "standard" ];
      };
      "datapool/ntfy-sh" = {
        useTemplate = [ "standard" ];
      };
      "datapool/lldap" = {
        useTemplate = [ "standard" ];
      };
      "datapool/papra" = {
        useTemplate = [ "standard" ];
      };

      # Observability
      "datapool/grafana" = {
        useTemplate = [ "observability" ];
      };
      "datapool/prometheus2" = {
        useTemplate = [ "observability" ];
      };
      "datapool/loki" = {
        useTemplate = [ "observability" ];
      };
    };
  };
}
