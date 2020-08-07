#!/usr/bin/env bash

if [ "/usr/local/bin/brew" = "$(which brew)" ]; then
    echo "Homebrew installed...skipping"
else
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
