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
  # snowflake-labs-mcp = prev.callPackage ../pkgs/snowflake-labs-mcp { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      mcp = python-prev.mcp.overridePythonAttrs (old: {
        postPatch = "";
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
