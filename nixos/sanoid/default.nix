{ ... }:
#
# Sanoid manages ZFS snapshot retention for all datapool datasets.
# Syncoid handles offsite replication — set BACKUP_HOST below and ensure
# the syncoid SSH key is authorized on the remote before enabling it.
#
# On first deploy, create any missing ZFS datasets manually:
#   sudo zfs create -o mountpoint=/var/lib/actual       datapool/actual
#   sudo zfs create -o mountpoint=/var/lib/paperless    datapool/paperless
#   sudo zfs create -o mountpoint=/var/lib/couchdb      datapool/couchdb
#   sudo zfs create -o mountpoint=/var/lib/esphome      datapool/esphome
#   sudo zfs create -o mountpoint=/var/lib/zigbee2mqtt  datapool/zigbee2mqtt
#   sudo zfs create -o mountpoint=/var/lib/zwave-js-ui  datapool/zwave-js-ui
#   sudo zfs create -o mountpoint=/var/lib/caddy        datapool/caddy
#   sudo zfs create -o mountpoint=/var/lib/mosquitto    datapool/mosquitto
#   sudo zfs create -o mountpoint=/var/lib/uptime-kuma  datapool/uptime-kuma
#   sudo zfs create -o mountpoint=/var/lib/changedetection-io datapool/changedetection-io
#   sudo zfs create -o mountpoint=/var/lib/ntfy-sh      datapool/ntfy-sh
#   sudo zfs create -o mountpoint=/var/lib/radarr       datapool/radarr
#   sudo zfs create -o mountpoint=/var/lib/lldap        datapool/lldap
#
# Disaster recovery checklist:
#   1. NixOS config  — restore from git (github.com/rucas/derpfiles)
#   2. ZFS pool data — restore from offsite via syncoid / zfs recv
#   3. Age private key — restore from secure offline backup (KEEP THIS SAFE)
#   4. LUKS header    — restore with: cryptsetup luksHeaderRestore /dev/... --header-backup-file
#   Run `sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-header.img`
#   and store the result somewhere safe (encrypted USB, password manager attachment, etc.)
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
      "datapool/postgresql"       = { useTemplate = [ "critical" ]; };
      "datapool/hass"             = { useTemplate = [ "critical" ]; };
      "datapool/actual"           = { useTemplate = [ "critical" ]; };
      "datapool/paperless"        = { useTemplate = [ "critical" ]; };
      "datapool/couchdb"          = { useTemplate = [ "critical" ]; };
      "datapool/esphome"          = { useTemplate = [ "critical" ]; };
      "datapool/zigbee2mqtt"      = { useTemplate = [ "critical" ]; };
      "datapool/zwave-js-ui"      = { useTemplate = [ "critical" ]; };

      # Standard
      "datapool/adguardhome"      = { useTemplate = [ "standard" ]; };
      "datapool/caddy"            = { useTemplate = [ "standard" ]; };
      "datapool/mosquitto"        = { useTemplate = [ "standard" ]; };
      "datapool/uptime-kuma"      = { useTemplate = [ "standard" ]; };
      "datapool/changedetection-io" = { useTemplate = [ "standard" ]; };
      "datapool/ntfy-sh"          = { useTemplate = [ "standard" ]; };
      "datapool/radarr"           = { useTemplate = [ "standard" ]; };
      "datapool/lldap"            = { useTemplate = [ "standard" ]; };

      # Observability
      "datapool/grafana"          = { useTemplate = [ "observability" ]; };
      "datapool/prometheus2"      = { useTemplate = [ "observability" ]; };
      "datapool/loki"             = { useTemplate = [ "observability" ]; };
    };
  };

  # ---------------------------------------------------------------------------
  # Offsite replication via Syncoid
  #
  # Prereqs:
  #   1. Set BACKUP_USER and BACKUP_HOST below
  #   2. Generate an SSH key:  ssh-keygen -t ed25519 -f /etc/syncoid/id_ed25519
  #   3. Add the public key to authorized_keys on the backup host
  #   4. On the backup host: zfs create backup/rucaslab
  #   5. Set enable = true
  #
  # The syncoid user gets limited ZFS permissions — no pool-level access needed.
  # ---------------------------------------------------------------------------
  services.syncoid = {
    enable = false;
    user = "syncoid";

    # Run nightly at 2 AM
    interval = "*-*-* 02:00:00";

    commands =
      let
        BACKUP_USER = "syncoid";
        BACKUP_HOST = "your-backup-host-or-tailscale-ip"; # <-- SET THIS
        target = dataset: "${BACKUP_USER}@${BACKUP_HOST}:backup/rucaslab/${dataset}";
      in
      {
        "datapool/postgresql"   = { source = "datapool/postgresql";   target = target "postgresql";   sendOptions = "w"; recvOptions = "F"; };
        "datapool/hass"         = { source = "datapool/hass";         target = target "hass";         sendOptions = "w"; recvOptions = "F"; };
        "datapool/actual"       = { source = "datapool/actual";       target = target "actual";       sendOptions = "w"; recvOptions = "F"; };
        "datapool/paperless"    = { source = "datapool/paperless";    target = target "paperless";    sendOptions = "w"; recvOptions = "F"; };
        "datapool/couchdb"      = { source = "datapool/couchdb";      target = target "couchdb";      sendOptions = "w"; recvOptions = "F"; };
        "datapool/esphome"      = { source = "datapool/esphome";      target = target "esphome";      sendOptions = "w"; recvOptions = "F"; };
        "datapool/zigbee2mqtt"  = { source = "datapool/zigbee2mqtt";  target = target "zigbee2mqtt";  sendOptions = "w"; recvOptions = "F"; };
        "datapool/zwave-js-ui"  = { source = "datapool/zwave-js-ui";  target = target "zwave-js-ui";  sendOptions = "w"; recvOptions = "F"; };
        "datapool/adguardhome"  = { source = "datapool/adguardhome";  target = target "adguardhome";  sendOptions = "w"; recvOptions = "F"; };
        "datapool/caddy"        = { source = "datapool/caddy";        target = target "caddy";        sendOptions = "w"; recvOptions = "F"; };
        "datapool/mosquitto"    = { source = "datapool/mosquitto";    target = target "mosquitto";    sendOptions = "w"; recvOptions = "F"; };
        "datapool/lldap"        = { source = "datapool/lldap";        target = target "lldap";        sendOptions = "w"; recvOptions = "F"; };
        "datapool/grafana"      = { source = "datapool/grafana";      target = target "grafana";      sendOptions = "w"; recvOptions = "F"; };
      };
  };
}
