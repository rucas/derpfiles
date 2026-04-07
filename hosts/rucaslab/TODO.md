# rucaslab TODOs

## Pre-deploy (must do before `nixos-rebuild`)

### Create restic secrets

The `.age` files don't exist yet. Without them the build will fail.

1. Create an S3 bucket (e.g. `rucaslab-backup`) with Glacier Instant Retrieval lifecycle rule
2. Create an IAM user with S3 access (see `nixos/restic/default.nix` for the policy)
3. Generate and encrypt the secrets:
   ```bash
   cd hosts/rucaslab/secrets || exit
   agenix -e restic-aws-env.age      # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
   agenix -e restic-password.age     # restic encryption passphrase (store in 1Password too)
   ```

### Migrate services to ZFS datasets (before deploy)

Do the ZFS migrations below **before** deploying, so sanoid/restic have datasets to snapshot/back up.

Disko only runs at install time. These datasets are declared in `disko.nix` but may not exist
on the live system yet. For each service: stop it, create the ZFS dataset, copy data over, start it.

Skip any service whose dataset already exists (`zfs list datapool/<name>` returns success).

#### esphome

```bash
sudo systemctl stop esphome
sudo mv /var/lib/esphome /var/lib/esphome.bak
sudo zfs create -o mountpoint=/var/lib/esphome datapool/esphome
sudo cp -a /var/lib/esphome.bak/. /var/lib/esphome/
sudo systemctl start esphome
sudo rm -rf /var/lib/esphome.bak
```

#### zigbee2mqtt

```bash
sudo systemctl stop zigbee2mqtt
sudo mv /var/lib/zigbee2mqtt /var/lib/zigbee2mqtt.bak
sudo zfs create -o mountpoint=/var/lib/zigbee2mqtt datapool/zigbee2mqtt
sudo cp -a /var/lib/zigbee2mqtt.bak/. /var/lib/zigbee2mqtt/
sudo systemctl start zigbee2mqtt
sudo rm -rf /var/lib/zigbee2mqtt.bak
```

#### zwave-js-ui

```bash
sudo systemctl stop zwave-js-ui
sudo mv /var/lib/zwave-js-ui /var/lib/zwave-js-ui.bak
sudo zfs create -o mountpoint=/var/lib/zwave-js-ui datapool/zwave-js-ui
sudo cp -a /var/lib/zwave-js-ui.bak/. /var/lib/zwave-js-ui/
sudo systemctl start zwave-js-ui
sudo rm -rf /var/lib/zwave-js-ui.bak
```

#### mosquitto

```bash
sudo systemctl stop mosquitto
sudo mv /var/lib/mosquitto /var/lib/mosquitto.bak
sudo zfs create -o mountpoint=/var/lib/mosquitto datapool/mosquitto
sudo cp -a /var/lib/mosquitto.bak/. /var/lib/mosquitto/
sudo systemctl start mosquitto
sudo rm -rf /var/lib/mosquitto.bak
```

#### uptime-kuma

```bash
sudo systemctl stop uptime-kuma
sudo mv /var/lib/uptime-kuma /var/lib/uptime-kuma.bak
sudo zfs create -o mountpoint=/var/lib/uptime-kuma datapool/uptime-kuma
sudo cp -a /var/lib/uptime-kuma.bak/. /var/lib/uptime-kuma/
sudo systemctl start uptime-kuma
sudo rm -rf /var/lib/uptime-kuma.bak
```

#### changedetection-io

```bash
sudo systemctl stop changedetection-io
sudo mv /var/lib/changedetection-io /var/lib/changedetection-io.bak
sudo zfs create -o mountpoint=/var/lib/changedetection-io datapool/changedetection-io
sudo cp -a /var/lib/changedetection-io.bak/. /var/lib/changedetection-io/
sudo systemctl start changedetection-io
sudo rm -rf /var/lib/changedetection-io.bak
```

#### ntfy-sh

```bash
sudo systemctl stop ntfy-sh
sudo mv /var/lib/ntfy-sh /var/lib/ntfy-sh.bak
sudo zfs create -o mountpoint=/var/lib/ntfy-sh datapool/ntfy-sh
sudo cp -a /var/lib/ntfy-sh.bak/. /var/lib/ntfy-sh/
sudo systemctl start ntfy-sh
sudo rm -rf /var/lib/ntfy-sh.bak
```

#### lldap

```bash
sudo systemctl stop lldap
sudo mv /var/lib/lldap /var/lib/lldap.bak
sudo zfs create -o mountpoint=/var/lib/lldap datapool/lldap
sudo cp -a /var/lib/lldap.bak/. /var/lib/lldap/
sudo systemctl start lldap
sudo rm -rf /var/lib/lldap.bak
```

## Post-deploy verification

Run these after `nixos-rebuild switch` to confirm everything is working.

### ZFS datasets and snapshots

```bash
# All 14 datasets should be listed and mounted
zfs list -r datapool

# Sanoid should have created at least one snapshot per dataset
zfs list -t snapshot -r datapool | head -20

# Sanoid timer is active
systemctl status sanoid.timer
```

### Restic backups

```bash
# Timer is scheduled
systemctl status restic-backups-s3-glacier.timer

# Test a manual backup run (will also initialize the repo on first run)
sudo systemctl start restic-backups-s3-glacier.service
journalctl -u restic-backups-s3-glacier.service -e --no-pager

# Verify snapshots exist in the remote repo
sudo restic -r s3:s3.amazonaws.com/rucaslab-backup/restic snapshots \
  --password-file /run/agenix/restic-password
```

### PostgreSQL dumps

```bash
# Trigger a dump and check output
sudo systemctl start postgresqlBackup-authelia-rucaslab.service
ls -lh /var/backup/postgresql/
```

### Services health

```bash
# Quick check that all services came up after deploy
for svc in home-assistant esphome zigbee2mqtt zwave-js-ui mosquitto \
           adguardhome uptime-kuma changedetection-io ntfy-sh lldap \
           authelia caddy postgresql grafana prometheus loki; do
  systemctl is-active --quiet "$svc" && echo "OK  $svc" || echo "FAIL $svc"
done
```

### Tailscale and networking

```bash
tailscale status
curl -s -o /dev/null -w '%{http_code}' https://localhost:443 || true
```

## Post-deploy cleanup

- [ ] Remove leftover data directories from removed services:
  ```bash
  sudo rm -rf /var/lib/actual /var/lib/paperless /var/lib/radarr /var/lib/couchdb
  ```
