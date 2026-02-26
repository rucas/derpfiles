{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ledger-sync;

  watchScript = "${config.users.users.${cfg.user}.home}/Code/derpfiles/scripts/ledger-watch.sh";
  syncScript = "${config.users.users.${cfg.user}.home}/Code/derpfiles/scripts/ledger-sync.sh";

  logDir = "${config.users.users.${cfg.user}.home}/Library/Logs";

in
{
  options.services.ledger-sync = {
    enable = mkEnableOption "Automatic ledger sync service with file watching";

    user = mkOption {
      type = types.str;
      description = "User to run the ledger sync service as";
      example = "lucas.rondenet";
    };

    ledgerPath = mkOption {
      type = types.str;
      default = "${config.users.users.${cfg.user}.home}/Code/ledger";
      description = "Path to the ledger repository";
    };

    debounceSeconds = mkOption {
      type = types.int;
      default = 180;
      description = "Debounce period in seconds (time to wait after last file change before syncing)";
    };
  };

  config = mkIf cfg.enable {
    # Create a persistent launchd agent that runs the file watcher
    launchd.user.agents.ledger-sync-watcher = {
      serviceConfig = {
        Label = "com.rucas.ledger-sync.watcher";
        ProgramArguments = [ watchScript ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${logDir}/ledger-sync-watcher-stdout.log";
        StandardErrorPath = "${logDir}/ledger-sync-watcher-stderr.log";
        EnvironmentVariables = {
          PATH = "${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.fswatch}/bin:/usr/bin:/bin";
          LEDGER_PATH = "${cfg.ledgerPath}";
          SYNC_SCRIPT = syncScript;
          LOG_FILE = "${logDir}/ledger-sync.log";
          WATCHER_LOG_FILE = "${logDir}/ledger-watch.log";
          DEBOUNCE_SECONDS = toString cfg.debounceSeconds;
        };
      };
    };
  };
}
