{ config, options, lib, pkgs, ... }: {
  homebrew = {
    enable = true;
    onActivation = { cleanup = "zap"; };
    taps = [ "homebrew/cask-fonts" "bradyjoslin/sharewifi" ];
    casks = [
      "1password"
      "aerial"
      "appcleaner"
      "blackhole-16ch"
      "dash"
      "dropbox"
      "slack"
      "obs"
      "vlc"
    ];
    brews = [ "blueutil" "chrome-cli" "pyenv" "sharewifi" ];
  };

  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
}
