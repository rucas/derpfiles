#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# shellcheck source=setup/brew.sh
. "$DIR/brew.sh"

# shellcheck source=setup/tpm.sh
. "$DIR/tpm.sh"

# shellcheck source=setup/vimplug.sh
. "$DIR/vimplug.sh"

# shellcheck source=setup/zplug.sh
. "$DIR/zplug.sh"


#pip3 install neovim
