# FAQ

## how do I update claude-code?

### Run the update script

```bash
$ nix-shell -p nodejs --run "cd pkgs/claude-code && bash update.sh"
```

This will:
1. Download the latest claude-code version from npm
2. Generate a new package-lock.json
3. Update the version and source hash in default.nix

### Build and fix npmDepsHash

```bash
$ nix build .#claude-code
```

If the npmDepsHash is incorrect, nix will show the correct hash. Update it in `pkgs/claude-code/default.nix` and rebuild.

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
