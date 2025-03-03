{ pkgs, inputs, ... }: {
  imports = [ inputs.betterfox-nix.homeManagerModules.betterfox ];

  # NOTE:
  # might need to run
  # MOZ_LEGACY_PROFILES=1 ~/Applications/Home\ Manager\ Apps/Firefox.app/Contents/MacOS/firefox
  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = 1;
    MOZ_ALLOW_DOWNGRADE = 1;
  };

  programs.firefox = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.firefox-bin else null;
    betterfox.enable = true;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        gruvbox-dark-theme
        onepassword-password-manager
        react-devtools
        ublock-origin
      ];

      betterfox = {
        enable = true;
        enableAllSections = true;
        fastfox.enable = true;
        peskyfox.enable = true;
        securefox.enable = true;
      };

      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Wiki" = {
            urls = [{
              template = "https://nixos.wiki/index.php?search={searchTerms}";
            }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "Google".metaData.alias = "@g";
        };
      };

      settings = {
        # Disable "save password" prompt
        "signon.rememberSignons" = false;
        # Dont warn on CMD+Q
        "browser.warnOnQuit" = false;
      };

      bookmarks = [
        {
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        }
        {
          name = "kernel.org";
          url = "https://www.kernel.org";
        }
        {
          name = "Nix sites";
          bookmarks = [
            {
              name = "homepage";
              url = "https://nixos.org/";
            }
            {
              name = "wiki";
              tags = [ "wiki" "nix" ];
              url = "https://wiki.nixos.org/";
            }
          ];
        }
      ];
    };
  };
}
