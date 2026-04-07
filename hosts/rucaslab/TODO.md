# rucaslab TODOs

## Post-deploy cleanup

- [ ] Remove leftover data directories if they exist on the live host:
  ```bash
  sudo rm -rf /var/lib/actual /var/lib/paperless /var/lib/radarr /var/lib/couchdb
  ```

## Migrate services to ZFS datasets

Disko only runs at install time. These datasets are declared in `disko.nix` but may not exist
on the live system yet. For each service: stop it, create the ZFS dataset, copy data over, start it.

Skip any service whose dataset already exists (`zfs list datapool/<name>` returns success).

### esphome

```bash
sudo systemctl stop esphome
sudo mv /var/lib/esphome /var/lib/esphome.bak
sudo zfs create -o mountpoint=/var/lib/esphome datapool/esphome
sudo cp -a /var/lib/esphome.bak/. /var/lib/esphome/
sudo systemctl start esphome
sudo rm -rf /var/lib/esphome.bak
```

### zigbee2mqtt

```bash
sudo systemctl stop zigbee2mqtt
sudo mv /var/lib/zigbee2mqtt /var/lib/zigbee2mqtt.bak
sudo zfs create -o mountpoint=/var/lib/zigbee2mqtt datapool/zigbee2mqtt
sudo cp -a /var/lib/zigbee2mqtt.bak/. /var/lib/zigbee2mqtt/
sudo systemctl start zigbee2mqtt
sudo rm -rf /var/lib/zigbee2mqtt.bak
```

### zwave-js-ui

```bash
sudo systemctl stop zwave-js-ui
sudo mv /var/lib/zwave-js-ui /var/lib/zwave-js-ui.bak
sudo zfs create -o mountpoint=/var/lib/zwave-js-ui datapool/zwave-js-ui
sudo cp -a /var/lib/zwave-js-ui.bak/. /var/lib/zwave-js-ui/
sudo systemctl start zwave-js-ui
sudo rm -rf /var/lib/zwave-js-ui.bak
```

### mosquitto

```bash
sudo systemctl stop mosquitto
sudo mv /var/lib/mosquitto /var/lib/mosquitto.bak
sudo zfs create -o mountpoint=/var/lib/mosquitto datapool/mosquitto
sudo cp -a /var/lib/mosquitto.bak/. /var/lib/mosquitto/
sudo systemctl start mosquitto
sudo rm -rf /var/lib/mosquitto.bak
```

### uptime-kuma

```bash
sudo systemctl stop uptime-kuma
sudo mv /var/lib/uptime-kuma /var/lib/uptime-kuma.bak
sudo zfs create -o mountpoint=/var/lib/uptime-kuma datapool/uptime-kuma
sudo cp -a /var/lib/uptime-kuma.bak/. /var/lib/uptime-kuma/
sudo systemctl start uptime-kuma
sudo rm -rf /var/lib/uptime-kuma.bak
```

### changedetection-io

```bash
sudo systemctl stop changedetection-io
sudo mv /var/lib/changedetection-io /var/lib/changedetection-io.bak
sudo zfs create -o mountpoint=/var/lib/changedetection-io datapool/changedetection-io
sudo cp -a /var/lib/changedetection-io.bak/. /var/lib/changedetection-io/
sudo systemctl start changedetection-io
sudo rm -rf /var/lib/changedetection-io.bak
```

### ntfy-sh

```bash
sudo systemctl stop ntfy-sh
sudo mv /var/lib/ntfy-sh /var/lib/ntfy-sh.bak
sudo zfs create -o mountpoint=/var/lib/ntfy-sh datapool/ntfy-sh
sudo cp -a /var/lib/ntfy-sh.bak/. /var/lib/ntfy-sh/
sudo systemctl start ntfy-sh
sudo rm -rf /var/lib/ntfy-sh.bak
```

### lldap

```bash
sudo systemctl stop lldap
sudo mv /var/lib/lldap /var/lib/lldap.bak
sudo zfs create -o mountpoint=/var/lib/lldap datapool/lldap
sudo cp -a /var/lib/lldap.bak/. /var/lib/lldap/
sudo systemctl start lldap
sudo rm -rf /var/lib/lldap.bak
```
