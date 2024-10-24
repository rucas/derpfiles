{ pkgs, inputs, ... }: {
  imports = [ inputs.arkenfox.hmModules.default ];

  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = 1;
    MOZ_ALLOW_DOWNGRADE = 1;
  };

  programs.firefox = {
    enable = true;
    package = null;
    arkenfox = { enable = true; };
    profiles.work = {
      extensions = with inputs.firefox-addons.packages.${pkgs.stdenv.system}; [
        gruvbox-dark-theme
        onepassword-password-manager
        react-devtools
        ublock-origin
      ];

      arkenfox = {
        enable = true;
        "0000".enable = true;
        "0100" = {
          enable = true;
          "0102"."browser.startup.page".value = 1;
          "0103"."browser.startup.homepage".value = "about:home";
        };
        "0200".enable = true;
        "0300".enable = true;
        "0400".enable = true;
        "0600".enable = true;
        "0800".enable = true;
        "0900".enable = true;
        "1200".enable = true;
        "1600".enable = true;
        "2600".enable = true;
        "2700".enable = true;
        "2800".enable = true;
        "4000".enable = true;
        "4500".enable = true;
        "5000" = {
          enable = true;
          "5003"."signon.rememberSignons".value = false;
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
