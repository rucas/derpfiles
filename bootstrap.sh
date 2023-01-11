#!/usr/bin/env bash 
set -euo pipefail
# TODO: set up to work for both osx and ubuntu
if ! command -v nix &> /dev/null 
then
   sh <(curl -L https://nixos.org/nix/install)
   nix-env -iA nixpkgs.nixFlakes
fi

if [[ ! -e ~/.config/nix/nix.conf ]]; then
    mkdir -p ~/.config/nix
    cat >> ~/.config/nix/nix.conf <<EOL
experimental-features = nix-command flakes
EOL
fi

mkdir -p ~/.config/nixpkgs

