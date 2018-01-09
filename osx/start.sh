#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# shellcheck source=osx/airport.sh
. "$DIR/airport.sh"

# shellcheck source=osx/appstoreupdates.sh
. "$DIR/appstoreupdates.sh"

# shellcheck source=osx/debugdevelopsafari.sh
. "$DIR/debugdevelopsafari.sh"

# shellcheck source=osx/disableapplesendingdata.sh
. "$DIR/disableapplesendingdata.sh"

# shellcheck source=osx/disableguestaccount.sh
. "$DIR/disableguestaccount.sh"

# shellcheck source=osx/disablemotionsensorssd.sh
. "$DIR/disablemotionsensorssd.sh"

# shellcheck source=osx/enablefirewall.sh
. "$DIR/enablefirewall.sh"

# shellcheck source=osx/keyrepeat.sh
. "$DIR/hidemenubar.sh"

# shellcheck source=osx/keyrepeat.sh
. "$DIR/keyrepeat.sh"

# shellcheck source=osx/mapcapslocktoctrl.sh
. "$DIR/mapcapslocktoctrl.sh"

# shellcheck source=osx/keyrepeat.sh
. "$DIR/noadobeonstart.sh"

# shellcheck source=osx/nodashboard.sh
. "$DIR/nodashboard.sh"

# shellcheck source=osx/noDS_Store.sh
. "$DIR/noDS_Store.sh"

# shellcheck source=osx/onlyactiveappsdock.sh
. "$DIR/onlyactiveappsdock.sh"

# shellcheck source=osx/showdrivesondesktop.sh
. "$DIR/showdrivesondesktop.sh"
