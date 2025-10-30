<img src="artwork/thor.gif" align="center" />

<h1 align="center">derpfiles</h1>

> Some hidden files that keep me sane...

## Table of Contents

- [Install](#install)
- [Contribute](#contribute)
- [License](#license)

## Install

### OS X System

Install nix via [DeterminateSystems/nix-installer](https://github.com/DeterminateSystems/nix-installer).
This has flakes enabled by default.

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix
| sh -s -- install
```

install homebrew

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# make sure to follow steps at end to add brew to $PATH
```

mkdirs in `~`

```sh
$ mkdir ~/Code
$ mkdir ~/Work
```

clone repo

```sh
$ git clone https://github.com/rucas/derpfiles.git
```

optionally, add a github token to bypass 429 rate limits from Github

```sh
vi ~/.config/nix/nix.conf
access-tokens = github.com=******
```

start nix build

```sh
$ nix build --impure '.#darwinConfigurations.[HOSTNAME].system'
```

let nix-darwin take the wheel...

```sh
$ ./result/sw/bin/darwin-rebuild switch --flake '.#[HOSTNAME]' --impure

# you may get an error on first run...
# follow the instructions...
#
# error: Directory /run does not exist, aborting activation
# Create a symlink to /var/run with:
# ...
```

may get error about `/etc/nix/nix.conf` already exists. To fix:

```
$ sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.bak
```

## FAQ

### How do I update a flake input?

```sh
$ nix flake lock --update-input <INPUT>
```

### How do I update a nixpkgs in `home.packages` declared in home-manager and not as a flake?

```sh
$ nix flake lock --update-input nixpkgs
```

### How do I open the current terminal line in my editor in Normal mode (zsh-vi-mode)?

In Normal mode you can type `vv` to edit current command line in an editor

### Why is yabai, skhd, jankyboarders not running on startup?

There's weird error somewhere in nix-darwin that doesn't load the launch the plists

```sh
$ launchctl unload ~/Library/LaunchAgents/org.nixos.jankyborders.plist
$ launchctl load ~/Library/LaunchAgents/org.nixos.jankyborders.plist
$ launchctl unload ~/Library/LaunchAgents/org.nixos.skhd.plist
...
```

## Contribute

PRs accepted. Checkout [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT © Lucas Rondenet
