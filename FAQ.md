# FAQ

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
