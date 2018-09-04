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

# Build chunkwm
...

# Build skhdrc
...

# Set ubersicht widgets folder to ./ubersicht
...


```

## Usage

Checkout individual README's in directories for detailed descriptions

- [ chunkwm ](chunkwm/)

- [ git ](git/)

- [ homebrew ](homebrew/)

- [ iterm2 ](iterm2/)

- [ neovim ](neovim/)

- [ osx ](osx/)

- [ skhd ](skhd/)

- [ taskwarrior ](task/)

- [ tmux ](tmux/)

- [ ubersicht ](ubersicht/)

- [ zsh ](zsh/)

## Contribute

PRs accepted. Checkout [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT © Lucas Rondenet 
