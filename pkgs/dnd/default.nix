{ pkgs, ... }:

##writeShellApplication "dnd" ''
##  echo Hello fucker!!!
##''

##xdg.configFile."dnd/dnd.shortcut" {
##  text = ''sup''
##};

pkgs.writeShellApplication {
  name = "dnd";

  runtimeInputs = [ ];

  text = ''

    command="$(basename "$0")"

    help() {
      printf -- "Usage: %s <subcommand> [options]\n" "$command"
      printf -- "Subcommands:\n"
      printf -- "    on        Turn ON do-not-disturb (DND) mode\n"
      printf -- "    off       Turn OFF do-not-disturb (DND) mode\n"
      printf -- "    install   Install macos-focus-mode shortcut\n"
      printf -- "    toggle   Toggle do-not-disturb (DND) mode ON and OFF\n"
      printf -- "    status   Get the current status of do-not-disturb (DND) mode\n"
    }

    install() {
      open "$HOME/.config/dnd/macos-focus-mode.shortcut"
    }

    status() {
      if [[ "$(defaults read com.apple.controlcenter "NSStatusItem Visible FocusModes")" == 1 ]]; then
        echo "on"
      else
        echo "off"
      fi
    }

    subcommand="''${1:-}"
    case $subcommand in
      "")
        toggle
        ;;
      "-h" | "--help")
        help
        ;;
      *)
        shift
        ''${subcommand} "$@"
        ;;
    esac
  '';
}
