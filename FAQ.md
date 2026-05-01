# FAQ

## how do I update claude-code?

### Run the update script

```bash
$ cd pkgs/claude-code && bash update.sh
```

Or pin a specific version:

```bash
$ cd pkgs/claude-code && bash update.sh 2.1.126
```

This fetches the `manifest.json` for that version (or latest) from the upstream release bucket, which contains binary checksums for all platforms.

## how do I upgrade nix?

### Using determinate-nix?

```bash
$ sudo determinate-nixd upgrade
```


## nix-darwin didnt start yabai, skhd, jankyborders...what do I do?

### Restart the LaunchAgent

```bash
# Stop then start manually
$ launchctl stop org.nixos.jankyborders
$ launchctl start org.nixos.jankyborders

# Or unload/load the plist
$ launchctl unload ~/Library/LaunchAgents/org.nixos.jankyborders.plist
$ launchctl load ~/Library/LaunchAgents/org.nixos.jankyborders.plist
```
