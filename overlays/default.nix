# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }:
final: prev: {
  claude-code = prev.callPackage ../pkgs/claude-code { };
  yabai = prev.callPackage ../pkgs/yabai { };
  mcp-server-fetch = prev.callPackage ../pkgs/mcp-server-fetch { };
  mcp-server-git = prev.callPackage ../pkgs/mcp-server-git { };
  mcp-server-time = prev.callPackage ../pkgs/mcp-server-time { };
  rollbar-mcp-server = prev.callPackage ../pkgs/rollbar-mcp-server { };
  mcp-atlassian = prev.callPackage ../pkgs/mcp-atlassian { };
  ledger-sync = prev.callPackage ../pkgs/ledger-sync { };
  ledger-watch = prev.callPackage ../pkgs/ledger-watch {
    fswatch = if prev.stdenv.isDarwin then prev.fswatch else null;
    inotify-tools = if prev.stdenv.isLinux then prev.inotify-tools else null;
  };
  playwright-mcp = prev.callPackage ../pkgs/playwright-mcp { inherit (inputs) playwright-mcp; };
  snowflake-labs-mcp = prev.callPackage ../pkgs/snowflake-labs-mcp { };

  gcal = prev.gcal.overrideAttrs (oldAttrs: rec {
    version = "4.2.0";

    src = prev.fetchurl {
      url = "https://www.alteholz.dev/gnu/gcal-${version}.tar.xz";
      hash = "sha256-2L0tdBHnglHWcGSqDxymClI7+FbuPm2J0H2FoSM0eNw=";
    };

    patches = [ ];

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.pkg-config ];
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.check ];

    postPatch = ''
      sed -i '/^SUBDIRS/,/^$/{ /tests/d; }' Makefile.in
    '';

    doCheck = false;
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      mcp = python-prev.mcp.overridePythonAttrs (old: {
        postPatch = "";
        doCheck = false;
      });
    })
  ];

  gitui = prev.rustPlatform.buildRustPackage {
    pname = "gitui";
    version = "unstable";

    src = inputs.gitui;

    cargoLock = {
      lockFile = "${inputs.gitui}/Cargo.lock";
    };

    OPENSSL_NO_VENDOR = "1";

    nativeBuildInputs = with prev; [
      pkg-config
      cmake
      perl
      git
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

    doCheck = false;

    meta = prev.gitui.meta;
  };
  cc-safety-net = prev.stdenv.mkDerivation {
    pname = "cc-safety-net";
    version = "unstable";
    src = inputs.claude-code-safety-net;
    nativeBuildInputs = [ prev.makeWrapper ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/cc-safety-net
      cp -r dist $out/lib/cc-safety-net/
      mkdir -p $out/bin
      makeWrapper ${prev.nodejs}/bin/node $out/bin/cc-safety-net \
        --add-flags "$out/lib/cc-safety-net/dist/bin/cc-safety-net.js"
      runHook postInstall
    '';
    meta.mainProgram = "cc-safety-net";
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
