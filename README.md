<img src="artwork/thor.gif" align="center" />

<h1 align="center">derpfiles</h1>

> Some hidden files that keep me sane...

## Table of Contents

- [Install](#install)
- [Contribute](#contribute)
- [License](#license)

## Install

### OS X System

install nix multi-user mode

```sh
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

install homebrew

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# make sure to follow steps at end to add brew to $PATH
```

mkdir worksoace in `~`

```sh
$ mkdir ~/Code
$ mkdir ~/Work

```

clone repo

```sh
$ git clone https://github.com/rucas/derpfiles.git
```

enable flakes

```sh
mkdir -p ~/.config/nix
    cat >> ~/.config/nix/nix.conf <<EOL
experimental-features = nix-command flakes
EOL
```

reload the nix-daemon

```
$ launchctl remove org.nixos.nix-daemon 
$ launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'

# may get warning about using bootstrap instead... 
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

## Contribute

PRs accepted. Checkout [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT © Lucas Rondenet 
