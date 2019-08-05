#!/usr/bin/env bash

pyenv install 2.7.11
pyenv install 3.6.1

pyenv virtualenv 2.7.11 neovim2
pyenv virtualenv 3.6.1 neovim3

pyenv activate neovim2
pip install pynvim
pyenv which python  # Note the path

pyenv activate neovim3
pip install pynvim
pyenv which python  # Note the path
