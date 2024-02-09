{ lib, pkgs, ... }:
let
  yamlFormat = pkgs.formats.yaml { };
  inherit (lib) mkMerge optionalAttrs;
  inherit (pkgs.stdenv) isLinux isDarwin;
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
        vars = [{
          name = "clipboard";
          type = "clipboard";
        }];
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
        regex = ":(?P<TT_ID>APN-.*?)\\.";
        replace = "[{{TT_ID}}](https://taskei.amazon.dev/tasks/{{TT_ID}})";
      }
      {
        regex = ":(?P<CR_ID>CR-.*?)\\.";
        replace = "[{{CR_ID}}](https://code.amazon.com/reviews/{{CR_ID}})";
      }
    ];
  };
in mkMerge [
  (lib.mkIf isLinux {
    services.espanso = {
      enable = true;
      settings = settings;
    };
  })

  (lib.mkIf isDarwin {
    xdg.configFile."espanso/match/base.yml".source =
      yamlFormat.generate "default.yml" settings;
  })
]
