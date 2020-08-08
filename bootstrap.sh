#!/usr/bin/env bash

# zsh 
ln -sf "$(pwd)/zsh/zshrc" ~/.zshrc
ln -sf "$(pwd)/zsh/zshenv" ~/.zshenv
ln -sf "$(pwd)/zsh/zshsetopt" ~/.zshsetopt
ln -sf "$(pwd)/zsh/zshaliases" ~/.zshaliases
ln -sf "$(pwd)/zsh/zshfunctions" ~/.zshfunctions

# Vim
mkdir -p ~/.config/nvim
ln -sf "$(pwd)/neovim/vimrc" ~/.vimrc
ln -sf "$(pwd)/neovim/vimrc" ~/.config/nvim/init.vim
ln -sf "$(pwd)/neovim/coc-settings.json" ~/.config/nvim/coc-settings.json

# Tmux
mkdir -p ~/.tmux/bin
ln -sf "$(pwd)/tmux/tmux.conf" ~/.tmux.conf
ln -sf "$(pwd)/tmux/bin/wifi.sh" ~/.tmux/bin/wifi

# Git
ln -sf "$(pwd)/git/gitignore_global" ~/.gitignore_global
ln -sf "$(pwd)/git/gitconfig" ~/.gitconfig

# TaskWarrior
ln -sf "$(pwd)/taskwarrior/taskrc" ~/.taskrc

# Chunkwm
ln -sf "$(pwd)/chunkwm/chunkwmrc" ~/.chunkwmrc

# Skhd
ln -sf "$(pwd)/skhd/skhdrc" ~/.skhdrc

# Go
ln -sf "$(pwd)/go/cobra.yaml" ~/.cobra.yaml

# tig
ln -sf "$(pwd)/tig/tigrc" ~/.tigrc

# docker
ln -sf "$(pwd)/docker/dockerfuncs" ~/.dockerfuncs

# nvm
ln -sf "$(pwd)/nvm/default-packages" ~/.nvm/default-packages
