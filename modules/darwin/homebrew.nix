{ ... }: {
  homebrew = {
    enable = true;
    onActivation = { cleanup = "zap"; };
    taps = [ "bradyjoslin/sharewifi" "espanso/espanso" ];
    casks = [
      "1password"
      "aerial"
      "appcleaner"
      "balenaetcher"
      "blackhole-16ch"
      "dash"
      "docker"
      "dropbox"
      "dynobase"
      "espanso"
      "maccy"
      "mqttx"
      "mqtt-explorer"
      "obs"
      "shortcat"
      "sketch"
      "slack"
      "vlc"
    ];
    brews = [ "blueutil" "chrome-cli" "openssh" "pyenv" "sharewifi" "tor" ];
  };

  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
}
