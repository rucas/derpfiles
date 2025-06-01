{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.zwave-js-ui-rucas;

  jsonType = (pkgs.formats.json { }).type;

  configFile = pkgs.writeTextFile {
    name = "merge_settings.json";
    text = builtins.toJSON cfg.settings;
  };

in {
  # NOTE:
  # https://zwave-js.github.io/zwave-js-ui/#/guide/env-vars
  options.services.zwave-js-ui-rucas = with types; {
    enable = mkEnableOption "Enable zwave-js-ui service";

    package = mkOption {
      type = package;
      default = pkgs.zwave-js-ui;
    };

    user = mkOption {
      default = "zwave-js-ui";
      type = str;
      description = ''
        User account under which zwave-js-ui runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the zwave-js-ui service starts.
        :::
      '';
    };

    group = mkOption {
      default = "zwave-js-ui";
      type = str;
      description = ''
        Group account under which zwave-js-ui runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the zwave-js-ui eservice starts.
        :::
      '';
    };

    port = mkOption {
      type = port;
      default = 8091;
      description = ''
        Port to serve HTTP pages on.
      '';
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
      description = ''
        Open ports in the firewall for the zwave-js-ui web interface
      '';
    };

    dataDir = mkOption {
      type = path;
      default = "/var/lib/zwave-js-ui";
      description = ''
        The data directory for zwave-js-ui.
      '';
    };

    behindProxy = mkOption {
      type = bool;
      default = false;
      description = ''
        The express TRUST_PROXY env var.
      '';
    };

    timezone = mkOption {
      type = str;
      default = "America/Los_Angeles";
      description = ''
        The timezone to you want in the UI.
      '';
    };

    networkKeyFile = mkOption {
      type = path;
      description = ''
        The systemd environment file that holds all the zwave network hex keys.
        SEE: https://zwave-js.github.io/zwave-js-ui/#/guide/env-vars
      '';
    };

    settings = mkOption {
      description = ''
        The configuration for zwave-js-ui, see...
      '';
      default = { };
      type = submodule {
        freeformType = jsonType;
        options = {
          zwave = mkOption {
            description = "zwave settings";
            default = { };
            type = submodule {
              freeformType = jsonType;
              options = {
                port = mkOption {
                  type = path;
                  description = "The serial port for the zwave usb stick";
                };
                allowBootloaderOnly = mkOption {
                  type = bool;
                  default = false;
                  description = "Not sure what this is...";
                };
                commandsTimeout = mkOption {
                  type = int;
                  default = 60;
                  description = "The timeout for a command";
                };
                logLevel = mkOption {
                  type = str;
                  default = "Info";
                  description = "The LOGLEVEL for logging zwave";
                };
                logEnabled = mkOption {
                  type = bool;
                  default = true;
                  description = "To enable logs or not.";
                };
              };
            };
          };
          backup = mkOption {
            description = "Backup settings.";
            default = { };
            type = submodule {
              freeformType = jsonType;
              options = {
                storeBackup = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable backups.";
                };
                storeCron = mkOption {
                  default = "0 0 * * *";
                  type = str;
                  description = "Cron expression to schedule the job.";
                };
                storeKeep = mkOption {
                  default = 7;
                  type = int;
                  description = "Max number of files to keep as backups.";
                };
                nvmBackup = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable NVM backups.";
                };
                nvmBackupOnEvent = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable backup on event.";
                };
                nvmCron = mkOption {
                  default = "0 0 * * *";
                  type = str;
                  description = "Cron expression to schedule backup job";
                };
                nvmKeep = mkOption {
                  default = 7;
                  type = int;
                  description = "Max number of files to keep nvm backups.";
                };
              };
            };
          };
          ui = mkOption {
            description = "UI settings";
            default = { };
            type = submodule {
              freeformType = jsonType;
              options = {
                darkMode = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable dark mode.";
                };
                navTabs = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable navigation tabs.";
                };
                compactMode = mkOption {
                  default = false;
                  type = bool;
                  description = "Enable compact mode.";
                };
              };
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.zwave-js-ui = let stateDir = "zwave-js-ui";
    in {
      description = "zwave-js-ui";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        STORE_DIR = "%S/${stateDir}";
        BACKUPS_DIR = "%S/${stateDir}/backups";
        ZWAVE_JS_EXTERNAL_CONFIG = "%S/${stateDir}/.config-db";
        TRUST_PROXY = "${lib.trivial.boolToString cfg.behindProxy}";
        TZ = cfg.timezone;
      };

      preStart =
        # NOTE: merge the json
        ''
          cp "$STATE_DIRECTORY/settings.json" "$STATE_DIRECTORY/settings.json.bak"
          rm -f "$STATE_DIRECTORY/settings.json"
          ${pkgs.jq}/bin/jq -s ".[0] * .[1]" "$STATE_DIRECTORY/settings.json.bak" "${configFile}" > "$STATE_DIRECTORY/settings.json"
        '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/zwave-js-ui";
        StateDirectory = "zwave-js-ui";
        WorkingDirectory = "%S/${stateDir}";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        EnvironmentFile = cfg.networkKeyFile;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    users.users = optionalAttrs (cfg.user == "zwave-js-ui") {
      zwave-js-ui = {
        isSystemUser = true;
        group = cfg.group;
        extraGroups = [ "dialout" ];
        home = cfg.dataDir;
      };
    };

    users.groups =
      optionalAttrs (cfg.group == "zwave-js-ui") { zwave-js-ui = { }; };
  };
}
