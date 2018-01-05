#!/usr/bin/env bash

if [ -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    echo "vim-plug installed...skipping"
else
    echo "Installing vim-plug"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
