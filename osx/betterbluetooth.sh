#!/usr/bin/env bash

sudo defaults write bluetoothaudiod "Enable AptX codec" -bool true

sudo defaults write bluetoothaudiod "Enable AAC codec" -bool true
