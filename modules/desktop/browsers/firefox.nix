{ pkgs, osConfig, inputs, ... }:
let
  hostSpecificBookmarks = {
    "lronden-m-vy79p" = "firefox-bookmarks-a.yaml";
    "salus" = "firefox-bookmarks-b.yaml";
  };
  yamlToAttrs = yamlFile:
    let
      jsonFile =
        pkgs.runCommand "yaml-to-json" { buildInputs = [ pkgs.yq ]; } ''
          yq . ${yamlFile} > $out
        '';
    in builtins.fromJSON (builtins.readFile jsonFile);
  currentHostBookmarks =
    if builtins.hasAttr osConfig.networking.hostName hostSpecificBookmarks then
      yamlToAttrs (../../../secrets
        + "/${hostSpecificBookmarks.${osConfig.networking.hostName}}")
    else
      [ ];
in {
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
    package = if pkgs.stdenv.isDarwin then pkgs.firefox else null;
    betterfox.enable = true;
    policies = {
      FirefoxHome = {
        Search = true;
        Pocket = false;
        Snippets = false;
        TopSites = false;
        Highlights = false;
      };
    };
    profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        gruvbox-dark-theme
        onepassword-password-manager
        react-devtools
        sponsorblock
        unpaywall
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
            icon = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "google".metaData.alias = "@g";
        };
      };

      settings = {
        # Disable "save password" prompt
        "signon.rememberSignons" = false;
        # Dont warn on CMD+Q
        "browser.warnOnQuit" = false;

        # NOTE: https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening#sanitize-on-close
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cache" = true; # DEFAULT
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true; # DEFAULT
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" =
          true; # DEFAULT
        "privacy.clearOnShutdown_v2.siteSettings" = true;

        # PREF: after crashes or restarts, do not save extra session data
        # such as form content, scrollbar positions, and POST data
        "browser.sessionstore.privacy_level" = 2;
      };

      bookmarks = {
        force = true;
        settings = [
          {
            name = "wikipedia";
            tags = [ "wiki" ];
            keyword = "wiki";
            url =
              "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
          }
          {
            name = "kernel.org";
            url = "https://www.kernel.org";
          }
          {
            name = "bugmenot.com";
            url = "https://bugmenot.com/";
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
        ] ++ currentHostBookmarks;
      };
    };
  };
}
