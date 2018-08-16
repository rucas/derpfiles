#!/usr/bin/env bash

# NOTE: https://superuser.com/questions/12292/bluetooth-headphones-sound-terrible-on-mac-os-x?newreg=50d80785109445439dfe8d91b2083c6b

# force better codecs 
sudo defaults write bluetoothaudiod "Enable AptX codec" -bool true
sudo defaults write bluetoothaudiod "Enable AAC codec" -bool true

# better defaults when better codecs fallback
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool Min (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" 80
