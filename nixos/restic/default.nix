{ config, ... }:
#
# Offsite backups to AWS S3 with Glacier Instant Retrieval storage class.
#
# Prereqs — do these once before enabling:
#
# 1. Create an S3 bucket (e.g. rucaslab-backup) in your preferred region.
#    Enable versioning and set a lifecycle rule:
#      - Transition all objects to Glacier Instant Retrieval after 0 days
#      - Expire versions older than 365 days (optional, restic handles pruning)
#
# 2. Create an IAM user with the following inline policy (replace BUCKET):
#      {
#        "Version": "2012-10-17",
#        "Statement": [{
#          "Effect": "Allow",
#          "Action": ["s3:ListBucket","s3:GetBucketLocation"],
#          "Resource": "arn:aws:s3:::BUCKET"
#        },{
#          "Effect": "Allow",
#          "Action": ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
#          "Resource": "arn:aws:s3:::BUCKET/*"
#        }]
#      }
#    Generate an access key for this user.
#
# 3. Encrypt and add the two secrets (fill in your values then run agenix):
#      # restic-aws-env.age — AWS credentials as shell env vars
#      AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxxxx
#      AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#      AWS_DEFAULT_REGION=us-east-1
#
#      # restic-password.age — single line, the restic encryption passphrase
#      a-long-random-passphrase-store-in-1password
#
#    cd hosts/rucaslab/secrets
#    agenix -e restic-aws-env.age
#    agenix -e restic-password.age
#
# 4. Set your S3 bucket name in the `repository` field below.
#
# 5. On first run, restic will initialise the repository automatically
#    (initialize = true below).
#
# Restore: see BACKUP.md
{
  # PostgreSQL: dump all databases to /var/backup/postgresql before restic runs.
  # These dumps give consistent point-in-time snapshots of the DB layer.
  services.postgresqlBackup = {
    enable = true;
    databases = [
      "authelia-rucaslab"
      "hass"
      "lldap"
    ];
    # Run at 01:30 so dumps are ready when restic starts at 02:00
    startAt = "*-*-* 01:30:00";
    # Compress dumps
    compression = "gzip";
  };

  services.restic.backups.s3-glacier = {
    initialize = true;

    # Bucket name is not sensitive — set it here directly.
    # Format: s3:s3.amazonaws.com/BUCKET/PREFIX
    repository = "s3:s3.amazonaws.com/rucaslab-backup/restic";

    # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    environmentFile = config.age.secrets.restic-aws-env.path;
    passwordFile = config.age.secrets.restic-password.path;

    paths = [
      # PostgreSQL dumps (consistent, produced by postgresqlBackup at 01:30)
      "/var/backup/postgresql"

      # Critical — irreplaceable
      "/var/lib/hass"
      "/var/lib/actual"
      "/var/lib/paperless"
      "/var/lib/couchdb"
      "/var/lib/esphome"
      "/var/lib/zigbee2mqtt"
      "/var/lib/zwave-js-ui"

      # Standard — painful to recreate
      "/var/lib/AdGuardHome"
      "/var/lib/caddy"
      "/var/lib/mosquitto"
      "/var/lib/uptime-kuma"
      "/var/lib/changedetection-io"
      "/var/lib/ntfy-sh"
      "/var/lib/radarr"
      "/var/lib/lldap"
    ];

    exclude = [
      # Home Assistant: skip the large recorder SQLite DB — it's in PostgreSQL
      "/var/lib/hass/home-assistant_v2.db"
      "/var/lib/hass/home-assistant_v2.db-shm"
      "/var/lib/hass/home-assistant_v2.db-wal"
      # ESPHome: skip compiled firmware blobs (can be rebuilt)
      "/var/lib/esphome/.esphome/build"
      # Loki / Prometheus are observability data — large and regenerable,
      # excluded here; local Sanoid snapshots provide short-term protection
    ];

    # Use Glacier Instant Retrieval — same retrieval speed as Standard,
    # ~68% cheaper. Objects land in Standard first then S3 lifecycle moves
    # them to GLACIER_IR per the bucket policy.
    extraOptions = [ "s3.storage-class=GLACIER_IR" ];

    # Run nightly at 02:00 (after pg dumps at 01:30)
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };

    # Keep the last 14 daily, 8 weekly, 6 monthly, 2 yearly snapshots.
    # Run prune after every backup.
    pruneOpts = [
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 6"
      "--keep-yearly 2"
    ];
  };
}
