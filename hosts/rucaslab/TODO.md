# rucaslab TODOs

## Post-deploy cleanup

- [ ] Remove leftover data directories if they exist on the live host:
  ```bash
  sudo rm -rf /var/lib/actual /var/lib/paperless /var/lib/radarr /var/lib/couchdb
  ```
