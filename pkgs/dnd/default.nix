{ pkgs, ... }: {
  dnd = pkgs.writeShellScriptBin "dnd" ''
    echo Hello!
  '';
}
