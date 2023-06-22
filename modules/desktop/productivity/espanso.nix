{ lib, pkgs, ... }:
let
  yamlFormat = pkgs.formats.yaml { };
  inherit (lib) mkMerge optionalAttrs;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
  settings = {
    matches = [
      {
        trigger = ":date";
        replace = "{{date}}";
        vars = [{
          name = "date";
          type = "date";
          params = { format = "%m/%d/%Y"; };
        }];
      }
      {
        trigger = ":ip";
        replace = "{{output}}";
        vars = [{
          name = "output";
          type = "shell";
          params = { cmd = "curl 'https://api.ipify.org'"; };
        }];
      }
    ];
  };
in mkMerge [
  (optionalAttrs isLinux {
    services.espanso = {
      enable = true;
      settings = settings;
    };
  })

  (optionalAttrs isDarwin {
    xdg.configFile."espanso/match/base.yml".source =
      yamlFormat.generate "default.yml" settings;
  })
]
