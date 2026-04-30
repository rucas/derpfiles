{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ledger-sync;
  inherit (pkgs.stdenv) isDarwin isLinux;

  homeDir = config.home.homeDirectory;

  logDir = if isDarwin then "${homeDir}/Library/Logs" else "${homeDir}/.local/state/ledger-sync";

  envVars = {
    LEDGER_PATH = cfg.ledgerPath;
    LOG_FILE = "${logDir}/ledger-sync.log";
    WATCHER_LOG_FILE = "${logDir}/ledger-watch.log";
    DEBOUNCE_SECONDS = toString cfg.debounceSeconds;
  };
in
{
  options.services.ledger-sync = {
    enable = mkEnableOption "Automatic ledger sync service with file watching";

    ledgerPath = mkOption {
      type = types.str;
      default = "${homeDir}/Code/ledger";
      description = "Path to the ledger repository";
    };

    debounceSeconds = mkOption {
      type = types.int;
      default = 180;
      description = "Debounce period in seconds (time to wait after last file change before syncing)";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf isDarwin {
      launchd.agents.ledger-sync-watcher = {
        enable = true;
        config = {
          Label = "com.rucas.ledger-sync.watcher";
          ProgramArguments = [ "${pkgs.ledger-watch}/bin/ledger-watch" ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${logDir}/ledger-sync-watcher-stdout.log";
          StandardErrorPath = "${logDir}/ledger-sync-watcher-stderr.log";
          EnvironmentVariables = envVars;
        };
      };
    })

    (mkIf isLinux {
      systemd.user.services.ledger-sync-watcher = {
        Unit = {
          Description = "Ledger file watcher and sync service";
          After = [ "network-online.target" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.ledger-watch}/bin/ledger-watch";
          Restart = "on-failure";
          RestartSec = 10;
          Environment = mapAttrsToList (k: v: "${k}=${v}") envVars;
        };
      };
    })
  ]);
}
