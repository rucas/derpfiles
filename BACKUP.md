# rucaslab Disaster Recovery

This document covers the full rebuild of rucaslab from scratch after catastrophic hardware failure.

---

## What's backed up and where

| Layer | Tool | Where | Schedule |
|---|---|---|---|
| Local ZFS snapshots | Sanoid | `datapool` (4TB Samsung 870 EVO) | Hourly/daily/weekly/monthly |
| Offsite data backup | restic | AWS S3 → Glacier Instant Retrieval | Nightly 02:00 |
| PostgreSQL dumps | postgresqlBackup | `/var/backup/postgresql` → restic | Nightly 01:30 |
| NixOS configuration | git | github.com/rucas/derpfiles | On push |

---

## Before disaster strikes — things to keep safe

These cannot be recovered from the backups themselves. Store them in 1Password or on an encrypted USB.

1. **YubiKey** — the personal agenix identity is YubiKey-derived (`age1yubikey1q...`).
   Keep your YubiKey safe; it is the key material, not a file on disk.
   After a rebuild the SSH host key changes — update `hosts/rucaslab/secrets/secrets.nix`
   with the new host public key and re-encrypt all secrets with `agenix -e <file>.age`
   before running `nixos-rebuild`.

2. **LUKS header backup** — run this once and store the file:
   ```bash
   sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-rucaslab-boot.img
   ```
   If the LUKS metadata on the NVMe corrupts, this file is the only way back in.

3. **Restic password** — the encryption key for the S3 repository.
   Already in 1Password (via the `restic-password.age` secret), but keep a plain-text copy somewhere you can access without rucaslab running.

---

## Full rebuild procedure

### Step 0 — Confirm your backups are intact

```bash
# Check latest restic snapshot from any machine with AWS creds
export $(cat /path/to/restic-aws-env)
restic snapshots --last
```

---

### Step 1 — Boot NixOS installer

Download the NixOS minimal ISO and boot from USB.

---

### Step 2 — Partition and format disks

```bash
# Clone the config
nix-shell -p git --run "git clone https://github.com/rucas/derpfiles /tmp/derpfiles"

# Run disko to partition the NVMe and create the ZFS pool
sudo nix run github:nix-community/disko -- \
  --mode disko /tmp/derpfiles/hosts/rucaslab/disko.nix
```

This will:
- Format the NVMe: EFI (512M) + LUKS root + LUKS swap
- Create `datapool` on the Samsung 870 EVO
- Create all ZFS datasets with correct mountpoints

> **If the 4TB drive survived** and the pool is intact, skip the disko ZFS step and
> import the existing pool instead:
> ```bash
> sudo zpool import -f datapool
> ```

---

### Step 3 — Restore data from restic (S3 Glacier)

If the ZFS pool did not survive, restore from restic.

```bash
# Get the restic env from 1Password / your secure store
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
export RESTIC_REPOSITORY=s3:s3.amazonaws.com/rucaslab-backup/restic
export RESTIC_PASSWORD=...

# List available snapshots
restic snapshots

# Restore everything to the newly formatted datasets
restic restore latest --target /

# Or restore a specific path, e.g. just Home Assistant:
restic restore latest --target / --include /var/lib/hass
```

> **Glacier retrieval note:** Glacier Instant Retrieval has no retrieval delay —
> restores begin immediately. If you accidentally archived to Glacier Flexible
> Retrieval or Deep Archive, initiate a retrieval job in the AWS console first
> (3–5 hours for Flexible, 12 hours for Deep Archive).

---

### Step 4 — Restore PostgreSQL from dumps

If you restored the restic backup, the PostgreSQL dumps are at `/var/backup/postgresql/*.sql.gz`.
They will be imported after PostgreSQL is running (Step 7).

> If the `datapool/postgresql` ZFS dataset survived intact, skip the dump restore —
> the live data is already there.

---

### Step 5 — Install NixOS

```bash
# Mount the root filesystem (disko already did this, but if starting fresh)
mount /dev/mapper/cryptroot /mnt
mount /dev/disk/by-uuid/2DCD-7A19 /mnt/boot

# Install from the flake
nixos-install --flake /tmp/derpfiles#rucaslab --no-root-password
```

---

### Step 6 — Copy your age private key onto the new system

Before rebooting, plant your age key so agenix can decrypt secrets on first boot:

```bash
mkdir -p /mnt/root/.config/sops/age
cp /path/to/age-key.txt /mnt/root/.config/sops/age/keys.txt
chmod 600 /mnt/root/.config/sops/age/keys.txt
```

---

### Step 7 — Reboot and verify

```bash
reboot
```

After rebooting:

```bash
# Check all services are up
systemctl --failed

# Verify ZFS datasets mounted
zfs list

# If pg dumps need to be imported (only if pool didn't survive):
# Start PostgreSQL first, then:
gunzip -c /var/backup/postgresql/hass.sql.gz | psql -U hass hass
gunzip -c /var/backup/postgresql/lldap.sql.gz | psql -U lldap lldap
gunzip -c /var/backup/postgresql/authelia-rucaslab.sql.gz | psql -U authelia-rucaslab authelia-rucaslab

# Confirm restic is healthy
systemctl status restic-backups-s3-glacier.service
journalctl -u restic-backups-s3-glacier.service -n 50
```

---

## Verifying backups (run monthly)

```bash
# Check snapshots exist and are recent
restic snapshots --last

# Verify repository integrity (reads all pack files)
restic check

# Test a restore of a single file
restic restore latest --target /tmp/restic-test --include /var/lib/actual
ls /tmp/restic-test/var/lib/actual
rm -rf /tmp/restic-test

# Check Sanoid snapshots are accumulating
zfs list -t snapshot -o name,creation | grep datapool | tail -30

# Check restic timer ran successfully
systemctl status restic-backups-s3-glacier.timer
journalctl -u restic-backups-s3-glacier.service --since "24 hours ago"
```

---

## Services and their data locations

| Service | Data path | Backup method |
|---|---|---|
| Home Assistant | `/var/lib/hass` | Sanoid + restic |
| PostgreSQL (hass, lldap, authelia) | `/data/postgresql/14` | Sanoid + pg_dump → restic |
| Actual Budget | `/var/lib/actual` | Sanoid + restic |
| Paperless-NGX | `/var/lib/paperless` | Sanoid + restic |
| CouchDB (Obsidian) | `/var/lib/couchdb` | Sanoid + restic |
| ESPHome | `/var/lib/esphome` | Sanoid + restic |
| Zigbee2MQTT | `/var/lib/zigbee2mqtt` | Sanoid + restic |
| Z-Wave JS UI | `/var/lib/zwave-js-ui` | Sanoid + restic |
| AdGuard Home | `/var/lib/AdGuardHome` | Sanoid + restic |
| Caddy (TLS certs) | `/var/lib/caddy` | Sanoid + restic |
| Mosquitto | `/var/lib/mosquitto` | Sanoid + restic |
| Uptime Kuma | `/var/lib/uptime-kuma` | Sanoid + restic |
| Changedetection | `/var/lib/changedetection-io` | Sanoid + restic |
| ntfy | `/var/lib/ntfy-sh` | Sanoid + restic |
| Radarr | `/var/lib/radarr` | Sanoid + restic |
| LLDAP | `/var/lib/lldap` | Sanoid + restic (data in PG) |
| Grafana | `/data/grafana` | Sanoid (observability, not in restic) |
| Prometheus | `/var/lib/prometheus2` | Sanoid (observability, not in restic) |
| Loki | `/data/loki` | Sanoid (observability, not in restic) |

---

## Quick reference

```bash
# List recent restic snapshots
restic snapshots --last 5

# Restore single service (e.g. ESPHome) to running system
restic restore latest --target / --include /var/lib/esphome

# List ZFS snapshots for a dataset
zfs list -t snapshot datapool/hass

# Roll back a dataset to last snapshot (DESTRUCTIVE — stops service first)
systemctl stop home-assistant
zfs rollback datapool/hass@autosnap_$(date +%Y-%m-%d)_00:00:00_daily
systemctl start home-assistant
```
