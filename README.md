<img src="artwork/thor.gif" align="center" />

<h1 align="center">derpfiles</h1>

> Some hidden files that keep me sane...

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Contribute](#contribute)
- [License](#license)

## Install

## OS X System

install nix multi-user mode

```sh
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

install homebrew

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# make sure to follow steps at end to add brew to $PATH
```

mkdir `~/Code`

```sh
$ mkdir Code
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

*os x system*

```sh
$ cd setup
$ ./start.sh

$ cd homebrew
$ brew bundle

# Edit /etc/shells
$ sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'

# Then run iterm2 setup script
$ cd iterm2
$ ./start.sh

# Set dotfiles (.zshrc, .zshenv, .zshaliases, ...)
$ ./bootstrap.sh

# Quit terminal and open iTerm

# zplug will prompt for downloading zsh plugins
# procede with a Y

# Then run osx defaults (KeyRepeat, etc.)
$ cd osx
$ ./start.sh

# log out
# and then log back in to see osx changes

# Then run neovim setup script
$ cd neovim
$ ./start.sh

# Go into neovim
$ nvim

:PlugInstall
:UpdateRemotePlugins

# launch tmux
$ tmux new-session
# prefix - I to fetch plugins

# Set ubersicht widgets folder to ./ubersicht
...

```

## Usage

Checkout individual README's in directories for detailed descriptions

- [ yabai ](yabai/)

- [ git ](git/)

- [ github ](github/)

- [ go ](go/)

- [ homebrew ](homebrew/)

- [ iterm2 ](iterm2/)

- [ neovim ](neovim/)

- [ osx ](osx/)

- [ skhd ](skhd/)

- [ tmux ](tmux/)

- [ zsh ](zsh/)

## Contribute

PRs accepted. Checkout [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT © Lucas Rondenet 
