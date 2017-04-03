#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check for updates
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install GNU core utilities (those that come with OS X are outdated).
brew install coreutils

# Update curl
brew install curl

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Faster then grep
brew install the_silver_searcher

# Quicker man pages
brew install tldr

# Nicer way to view project structure
brew install tree

# Cool process viewer
brew install htop

# Neovim 
brew install neovim/neovim/neovim

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
brew install ack

# git
brew install git
brew install hub

# tmux
brew install tmux
brew install battery

# Python
brew install python
brew install python3

# Better json parsing
brew install jq

# brew cask
brew cask install aerial
brew cask install atom
brew cask install postman
brew cask install anybar
brew cask install appcleaner
brew cask install dash 
brew cask install dropbox
brew cask install google-chrome
brew cask install iterm2
brew cask install java
brew cask install omnigraffle
brew cask install ngrok
brew cask install slack
brew cask install transmission
brew cask install vlc
brew cask install virtualbox

# neovim +python support
sudo pip2 install neovim
sudo pip3 install neovim

# fonts!
brew tap caskroom/fonts             
brew cask install font-hack
