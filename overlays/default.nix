# NOTE: https://www.fbrs.io/nix-overlays/
{ self, inputs, ... }: {
  alacritty = (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (drv: rec {
      src = inputs.alacritty;
      cargoDeps = drv.cargoDeps.overrideAttrs (prev.lib.const {
        inherit src;
        outputHash = "sha256-3reMU7O3E7LXwvFlebm+oZ8QgK+gKPNhc35aW3ICZV0=";
      });
    });
  });
  yabai = (final: prev: {
    yabai = prev.yabai.overrideAttrs (old: {
      src = final.fetchzip {
        url =
          "https://github.com/koekeishiya/yabai/releases/download/v5.0.2/yabai-v5.0.2.tar.gz";
        sha256 = "sha256-NS8tMUgovhWqc6WdkNI4wKee411i/e/OE++JVc86kFE=";
      };
    });
  });
  vimPlugins = (final: prev: {
    vimPlugins = prev.vimPlugins
      // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
  });
}
