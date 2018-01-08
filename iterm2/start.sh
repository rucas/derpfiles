#!/usr/bin/env bash

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/repos/derpfiles/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
killall cfprefsd
