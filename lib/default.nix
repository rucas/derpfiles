{ pkgs }:
{
  yamlToAttrs =
    yamlFile:
    let
      jsonFile = pkgs.runCommand "yaml-to-json" { buildInputs = [ pkgs.yq ]; } ''
        yq . ${yamlFile} > $out
      '';
    in
    builtins.fromJSON (builtins.readFile jsonFile);
}
