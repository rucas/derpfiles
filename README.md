<img src="artwork/thor.gif" align="center" />

<h1 align="center">derpfiles</h1>

> Some hidden files that keep me sane...

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Contribute](#contribute)
- [License](#license)

## Install

*os x system*

```sh
$ cd setup
./start.sh

$ cd homebrew
brew bundle

# TODO: then run iterm2 setup script
$ cd iterm2
./start.sh

# Then run osx defaults (KeyRepeat, etc.)
$ cd osx
./start.sh

$ cd neovim
./start.sh

# Edit /etc/shells
$ sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'

# Quit terminal and open iTerm

# This is for sqlite zsh history
$ touch .zsh_history.db

# Go into neovim and run
:PlugInstall
:UpdateRemotePlugins

# Build chunkwm
...

# Build skhdrc
...

# Set ubersicht widgets folder to ./ubersicht
...

./install.sh
```

## Usage

Checkout individual README's in directories for detailed descriptions

- [ chunkwm ]()

- [ git ]()

- [ homebrew ]()

- [ iterm2 ]()

- [ neovim ]()

- [ osx ]()

- [ skhdrc ]()

- [ taskwarrior ]()

- [ tmux ]()

- [ ubersicht ]()

- [ zsh ]()

## Contribute

PRs accepted. Checkout [CONTRIBUTING.md](https://github.com/rucas/derpfiles/blob/master/CONTRIBUTING.md)

## License

MIT © Lucas Rondenet 
