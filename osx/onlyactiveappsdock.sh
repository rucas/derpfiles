#!/usr/bin/env bash

defaults write com.apple.dock static-only -bool true && \
killall Dock
