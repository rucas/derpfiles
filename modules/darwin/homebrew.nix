{ ... }: {
  homebrew = {
    enable = true;
    onActivation = { cleanup = "zap"; };
    taps = [ "bradyjoslin/sharewifi" "espanso/espanso" "homebrew/cask-fonts" ];
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
      "slack"
      "shortcat"
      "maccy"
      "obs"
      "vlc"
    ];
    brews = [ "blueutil" "chrome-cli" "pyenv" "sharewifi" "openssh" ];
  };

  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
}
