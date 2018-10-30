#!/usr/bin/env bash

pyenv install 2.7.11
pyenv install 3.5.6

pyenv virtualenv 2.7.11 neovim2
pyenv virtualenv 3.5.6 neovim3

pyenv activate neovim2
pip install neovim
pyenv which python  # Note the path

pyenv activate neovim3
pip install neovim
pyenv which python  # Note the path
