#!/usr/bin/env bash

if [ -d ~/.tmux/plugins/tpm ]; then
    echo "tpm installed...skipping"
else
    echo "Installing tpm"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
