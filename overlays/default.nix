# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: {
  yabai = (final: prev: { yabai = prev.callPackage ../pkgs/yabai { }; });
  vimPlugins = (final: prev: {
    vimPlugins = prev.vimPlugins
      // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
  });
  tmuxPlugins = (final: prev: {
    tmuxPlugins = prev.tmuxPlugins // {
      tmux-1password = prev.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-1password";
        version = "unstable-2024-01-30";
        src = inputs.tmux-1password;
        rtpFilePath = "plugin.tmux";
      };
    };
  });
  alacritty = (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (drv: rec {
      version = "0.13.2";
      pname = "alacritty";

      src = prev.fetchFromGitHub {
        owner = "alacritty";
        repo = pname;
        rev = "v${version}";
        sha256 = ''
          sha256-Nn/G7SkRuHXRSRgNjlmdX1G07sp7FPx8UyAn63Nivfg=
        '';
      };
      nativeBuildInputs = drv.nativeBuildInputs ++ [ prev.pkgs.scdoc ];
      postInstall = prev.lib.concatStrings [
        # The manpages have been moved to scdoc, but the derivation
        # expects these files to exist. Create blank files so that the gzip
        # command doesn't fail the build
        ''
          touch extra/alacritty.man
          touch extra/alacritty-msg.man
        ''
        # The sample configuration file has been removed and is not only
        # documented in the manpages.
        ''
          touch alacritty.yml
        ''
        drv.postInstall
        # These are the real manpages that need to be copied.
        ''
          scdoc < extra/man/alacritty.1.scd | gzip -c > "$out/share/man/man1/alacritty.1.gz"
          scdoc < extra/man/alacritty-msg.1.scd | gzip -c > "$out/share/man/man1/alacritty-msg.1.gz"
        ''
        # There are also several new manpages for the config.
        ''
          install -dm 755 "$out/share/man/man5"

          scdoc < extra/man/alacritty.5.scd | gzip -c > "$out/share/man/man5/alacritty.5.gz"
          scdoc < extra/man/alacritty-bindings.5.scd | gzip -c > "$out/share/man/man5/alacritty-bindings.5.gz"
        ''
      ];

      cargoDeps = drv.cargoDeps.overrideAttrs (prev.lib.const {
        inherit src;
        outputHash = "sha256-WvOKsk9UGIMkGH6BRfWOKsVY985lhjy7M3ikafL16+4=";
      });
    });
  });
  zwave-js-ui =
    (final: prev: { zwave-js-ui = prev.callPackage ../pkgs/zwave-js-ui { }; });
}
