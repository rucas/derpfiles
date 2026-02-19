{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
  inherit (lib) mkMerge;
  inherit (pkgs.stdenv) isLinux isDarwin;

  secretMatches =
    let
      secretPath = ../../../secrets + "/triggers-${osConfig.networking.hostName}.toml";
    in
    if builtins.pathExists secretPath then
      (builtins.fromTOML (builtins.readFile secretPath)).matches or [ ]
    else
      [ ];

  # NOTE: https://github.com/Lissy93/espanso-config
  settings = {
    matches = secretMatches ++ [
      {
        trigger = ":date";
        replace = "{{date}}";
        vars = [
          {
            name = "date";
            type = "date";
            params = {
              format = "%m/%d/%Y";
            };
          }
        ];
      }
      {
        trigger = ":ip";
        replace = "{{output}}";
        vars = [
          {
            name = "output";
            type = "shell";
            params = {
              cmd = "curl 'https://api.ipify.org'";
            };
          }
        ];
      }
      {
        trigger = ":md-break";
        replace = "&nbsp;";
      }
      {
        trigger = ":md-code";
        replace = ''
          ```
          $|$
          ```'';
      }
      {
        trigger = ":md-link";
        replace = "[$|$]({{clipboard}})";
        vars = [
          {
            name = "clipboard";
            type = "clipboard";
          }
        ];
      }
      {
        trigger = ":((";
        replace = "($|$)";
      }
      {
        trigger = ":[[";
        replace = "[$|$]";
      }
      {
        trigger = ":{{";
        replace = "{$|$}";
      }
      {
        trigger = ":<<";
        replace = "<$|$>";
      }
      {
        trigger = ":__";
        replace = "_$|$_";
      }
      {
        trigger = ":**";
        replace = "*$|$*";
      }
      {
        trigger = ":``";
        replace = "`$|$`";
      }
      {
        trigger = ":req";
        replace = "requirements";
      }
      {
        trigger = ":av";
        replace = "availability";
      }
    ];
  };
in
mkMerge [
  (lib.mkIf isLinux {
    services.espanso = {
      enable = true;
      settings = settings;
    };
  })

  (lib.mkIf isDarwin {
    xdg.configFile."espanso/match/base.yml".source = yamlFormat.generate "default.yml" settings;
  })
]
