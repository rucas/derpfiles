#!/usr/bin/env bash

set -e
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# zsh
ln -sf "$(pwd)/zsh/zshrc" ~/.zshrc
ln -sf "$(pwd)/zsh/zshenv" ~/.zshenv
ln -sf "$(pwd)/zsh/zshsetopt" ~/.zshsetopt
ln -sf "$(pwd)/zsh/zshaliases" ~/.zshaliases
ln -sf "$(pwd)/zsh/zshfunctions" ~/.zshfunctions
ln -sf "$(pwd)/zsh/zfuncs/" ~/.zsh/

# Vim
mkdir -p ~/.config/nvim
ln -sf "$(pwd)/neovim/vimrc" ~/.vimrc
ln -sf "$(pwd)/neovim/init.lua" ~/.config/nvim/init.lua
ln -sf "$(pwd)/neovim/lua" ~/.config/nvim/

# Tmux
mkdir -p ~/.tmux/bin
ln -sf "$(pwd)/tmux/tmux.conf" ~/.tmux.conf
ln -sf "$(pwd)/tmux/bin/wifi.sh" ~/.tmux/bin/wifi

# Git
ln -sf "$(pwd)/git/gitignore_global" ~/.gitignore_global
ln -sf "$(pwd)/git/gitconfig" ~/.gitconfig

# TaskWarrior
ln -sf "$(pwd)/taskwarrior/taskrc" ~/.taskrc

# yabai
ln -sf "$(pwd)/yabai/yabairc" ~/.yabairc

# skhd
ln -sf "$(pwd)/skhd/skhdrc" ~/.skhdrc

# Go
ln -sf "$(pwd)/go/cobra.yaml" ~/.cobra.yaml

# tig
ln -sf "$(pwd)/tig/tigrc" ~/.tigrc

# docker
ln -sf "$(pwd)/docker/dockerfuncs" ~/.dockerfuncs

# nvm
ln -sf "$(pwd)/nvm/default-packages" ~/.nvm/default-packages

# bat
mkdir -p ~/.config/bat
ln -sf "$(pwd)/bat/config" ~/.config/bat/config

# alacritty
ln -sf "$(pwd)/alacritty/alacritty.yml" ~/.alacritty.yml

# gh 
mkdir -p ~/.config/gh
ln -sf "$(pwd)/gh/config.yml" ~/.config/gh/config.yml

# vale
mkdir -p  ~/.config/vale
ln -sf "$(pwd)/vale/vale.ini" ~/.vale.ini
ln -sf "$(pwd)/vale/styles" ~/.config/vale

# ptpython
mkdir -p  ~/.config/ptpython
ln -sf "$(pwd)/ptpython/config.py" ~/.config/ptpython/config.py

# FZF key bindings and fuzzy completion
if [ -f ~/.fzf.zsh ]; then
  echo 'FZF key bindings, and completion already installed...skipping'
else
  "$(brew --prefix)/opt/fzf/install"
fi
