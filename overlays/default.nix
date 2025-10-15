# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }:
final: prev: {
  claude-code = prev.callPackage ../pkgs/claude-code { };
  yabai = prev.callPackage ../pkgs/yabai { };

  # Fix GTK3 sincos detection with clang (backport from GTK MR 5531)
  # See: https://github.com/NixOS/nixpkgs/pull/449689
  gtk3 = prev.gtk3.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        name = "gtk3-fix-sincos-detection-clang.patch";
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/pull/449689/head/pkgs/development/libraries/gtk/patches/3.0-mr5531-backport.patch";
        hash = "sha256-vP0xmeKQazr93bTV+2kIwsNA+rZPmNd9iaUfpYOpD0M=";
      })
    ];
  });

  # Fix Firefox crash on macOS by using GTK2 for libcanberra
  # See: https://github.com/NixOS/nixpkgs/issues/451884#issuecomment-3401152877
  libcanberra = prev.libcanberra.override { gtkSupport = "gtk2"; };

  gitui = prev.rustPlatform.buildRustPackage rec {
    pname = "gitui";
    version = "unstable-2025-10-13";

    src = prev.fetchFromGitHub {
      owner = "extrawurst";
      repo = "gitui";
      rev = "180368621e09256b15cef9552e952abc6c934b88";
      hash = "sha256-S1Dv/hf+SAqbfSsLx2g7s2kT25qBikNd6CDGXikFyFk=";
    };

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    BUILD_GIT_COMMIT_ID = "1803686";

    # Use system OpenSSL instead of building from source
    OPENSSL_NO_VENDOR = "1";

    nativeBuildInputs = with prev; [
      pkg-config
      cmake
      perl
    ];

    buildInputs =
      with prev;
      [
        openssl
        zlib
      ]
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
        libiconv
      ];

    # Disable unnecessary features that might pull in GTK
    buildNoDefaultFeatures = false;

    # Skip tests - one test fails in Nix sandbox due to read-only filesystem
    doCheck = false;

    meta = prev.gitui.meta;
  };
  tmuxPlugins = prev.tmuxPlugins // {
    tmux-1password = prev.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-1password";
      version = "unstable-2024-01-30";
      src = inputs.tmux-1password;
      rtpFilePath = "plugin.tmux";
    };
    tmux-pomodoro-plus = prev.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-pomodoro-plus";
      version = "unstable-2025-10-15";
      src = inputs.tmux-pomodoro-plus;
      rtpFilePath = "pomodoro.tmux";
    };
  };
  home-assistant-custom-lovelace-modules = prev.home-assistant-custom-lovelace-modules // {
    lovelace-layout-card = prev.callPackage ../pkgs/lovelace-layout-card { };
    bubble-card = prev.callPackage ../pkgs/bubble-card { };
  };
  home-assistant-themes = {
    graphite = prev.callPackage ../pkgs/graphite { };
  };
}
