{ config, ... }:
let
  hostSpecificCasks = {
    "lronden-m-vy79p" = [ "slack" ];
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
    "maccy"
    "obs"
    "shortcat"
  ];
in {
  homebrew = {
    enable = true;
    onActivation = { cleanup = "zap"; };
    taps = [ "bradyjoslin/sharewifi" "espanso/espanso" ];
    casks = commonCasks
      ++ (hostSpecificCasks.${config.networking.hostName} or [ ]);
    brews = [ "blueutil" "chrome-cli" "openssh" "pyenv" "tor" ];
  };

  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
}
