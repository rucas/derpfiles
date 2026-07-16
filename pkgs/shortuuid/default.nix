{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "shortuuid";

  text = ''
    shortuuid () {
      uuidgen -hdr | tail -n 1 | cut -d',' -f 2- | xxd -r -p | base64 | tr '/+' '_-' | tr -d '='
    }

    shortuuid "$@"
  '';
}
