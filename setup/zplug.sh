#!/usr/bin/env bash

if [ -d ~/.zplug ]; then
    echo "zplug installed...skipping"
else
    echo "Installing zplug"
    curl -sL \
        --proto-redir \
        -all,https \
        https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
