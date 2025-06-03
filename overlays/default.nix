# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: {
  yabai = (final: prev: { yabai = prev.callPackage ../pkgs/yabai { }; });
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
  home-assistant-custom-components = (final: prev: {
    home-assistant-custom-components = prev.home-assistant-custom-components
      // {
        alarmo = prev.callPackage ../pkgs/alarmo { };
      };
  });
  home-assistant-custom-lovelace-modules = (final: prev: {
    home-assistant-custom-lovelace-modules =
      prev.home-assistant-custom-lovelace-modules // {
        lovelace-layout-card =
          prev.callPackage ../pkgs/lovelace-layout-card { };
        bubble-card = prev.callPackage ../pkgs/bubble-card { };
      };
  });
  home-assistant-themes = (final: prev: {
    home-assistant-themes = {
      graphite = prev.callPackage ../pkgs/graphite { };
    };
  });
}
