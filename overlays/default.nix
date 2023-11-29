# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: {
  yabai = (final: prev: { yabai = prev.callPackage ../pkgs/yabai { }; });
  vimPlugins = (final: prev: {
    vimPlugins = prev.vimPlugins
      // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
  });
}
