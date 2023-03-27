# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: {
  alacritty = (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (drv: rec {
      src = inputs.alacritty;
      cargoDeps = drv.cargoDeps.overrideAttrs (prev.lib.const {
        inherit src;
        outputHash = "sha256-zOU8DCUaPaykaD7JEc/ZHMKX0q+bm3RpruoyTisNeJ0=";
      });
    });
  });
  yabai = (final: prev: { yabai = prev.callPackage ../pkgs/yabai { }; });
  vimPlugins = (final: prev: {
    vimPlugins = prev.vimPlugins
      // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
  });
}
