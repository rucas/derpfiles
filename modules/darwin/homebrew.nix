{ config, ... }:
let
  hostSpecificCasks = {
    "salus" = [ "granola" "slack" ];
    "lronden-m-vy79p" = [ "intellij-idea" "granola" "slack" ];
    "blkmrkt" = [ "balenaetcher" "mqttx" "mqtt-explorer" "tailscale" "vlc" ];
  };

  commonCasks = [
    "1password"
    "aerial"
    "appcleaner"
    "blackhole-16ch"
    "dash"
    "docker"
    "dynobase"
    "espanso"
    "google-chrome"
    "insta360-link-controller"
    "maccy"
    "obs"
    "shortcat"
  ];
in {
  homebrew = {
    enable = true;
    onActivation = { cleanup = "zap"; };
    taps = [ "bradyjoslin/sharewifi" "espanso/espanso" "sdkman/tap" ];
    casks = commonCasks
      ++ (hostSpecificCasks.${config.networking.hostName} or [ ]);
    brews = [
      "blueutil"
      "chrome-cli"
      "openssh"
      "pyenv"
      "pyenv-virtualenv"
      "sdkman-cli"
      "tor"
      "zlib" # needed for pyenv shit
    ];
  };

  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
}
