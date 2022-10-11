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
      "chrome-cli"
      "dash"
      "dropbox"
      "slack"
      "obs"
      "vlc"
    ];
    brews = [ "sharewifi" ];
  };
}
