{ config, ... }:
let
  hostSpecific = {
    brews = {
      "lronden-m-vy79p" = [
        "gnu-getopt"
        "libffi" # needed for pyenv shit
        "pyenv"
        "pyenv-virtualenv"
        "sdkman-cli"
        "zlib" # needed for pyenv shit
      ];
    };
    casks = {
      "salus" = [
        "granola"
        "slack"
      ];
      "lronden-m-vy79p" = [
        "granola"
        "intellij-idea"
        "jetbrains-gateway"
        "postman"
        "slack"
      ];
      "blkmrkt" = [
        "balenaetcher"
        "mqttx"
        "mqtt-explorer"
        "tailscale-app"
        "vlc"
      ];
    };
  };

  common = {
    brews = [
      "blueutil"
      "openssh"
      "tor"
    ];
    casks = [
      "1password"
      "aerial"
      "appcleaner"
      "blackhole-16ch"
      "dash"
      "docker-desktop"
      "dynobase"
      "espanso"
      "google-chrome"
      "insta360-link-controller"
      "maccy"
      "monodraw"
      "obs"
      "shortcat"
      "spotify"
    ];
  };
in
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    taps = [
      "bradyjoslin/sharewifi"
      "espanso/espanso"
      "sdkman/tap"
    ];
    casks = common.casks ++ (hostSpecific.casks.${config.networking.hostName} or [ ]);
    brews = common.brews ++ (hostSpecific.brews.${config.networking.hostName} or [ ]);
  };

  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
