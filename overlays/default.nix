# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: final: prev: {
  yabai = prev.callPackage ../pkgs/yabai { };
  tmuxPlugins = prev.tmuxPlugins // {
    tmux-1password = prev.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-1password";
      version = "unstable-2024-01-30";
      src = inputs.tmux-1password;
      rtpFilePath = "plugin.tmux";
    };
  };
  home-assistant-custom-lovelace-modules =
    prev.home-assistant-custom-lovelace-modules // {
      lovelace-layout-card =
        prev.callPackage ../pkgs/lovelace-layout-card { };
      bubble-card = prev.callPackage ../pkgs/bubble-card { };
    };
  home-assistant-themes = {
    graphite = prev.callPackage ../pkgs/graphite { };
  };
}
