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
        "uv"
      ];
    };
    casks = {
      "salus" = [
        "1password"
        "slack"
      ];
      "lronden-m-vy79p" = [
        "intellij-idea"
        "jetbrains-gateway"
        "postman"
      ];
      "blkmrkt" = [
        "1password"
        "balenaetcher"
        "garmin-express"
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
    # NOTE: 1password is per-host: on work laptops MDM owns /Applications and
    # brew's cask upgrade fights it, so it is not in the common list.
    casks = [
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

  # The `brew bundle` step runs via `sudo --preserve-env=PATH`, so shell env
  # vars never reach it. Taps are pinned declaratively above, so disable
  # Homebrew 6's tap-trust gate through its system-wide environment file
  # instead (otherwise the rebuild fails on untrusted taps like sdkman/tap).
  environment.etc."homebrew/brew.env".text = ''
    HOMEBREW_NO_ANALYTICS=1
    HOMEBREW_NO_REQUIRE_TAP_TRUST=1
  '';
}
