{ lib, pkgs, config, ... }:

with lib;

let cfg = config.services.zwave-js-ui;

in {
  # NOTE:
  # https://zwave-js.github.io/zwave-js-ui/#/guide/env-vars
  options.services.zwave-js-ui = with types; {
    enable = mkEnableOption "Enable zwave-js-ui service";

    package = mkOption {
      type = package;
      default = pkgs.zwave-js-ui;
    };

    user = mkOption {
      default = "zwave-js-ui";
      type = types.str;
      description = lib.mdDoc ''
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
      type = types.str;
      description = lib.mdDoc ''
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
      description = lib.mdDoc ''
        Port to serve HTTP pages on.
      '';
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
      description = lib.mdDoc ''
        Open ports in the firewall for the zwave-js-ui web interface
      '';
    };

    device = mkOption {
      type = path;
      example = "/dev/serial/by-id/insert_stick_reference_here";
      description = "The serial port for the zwave usb stick";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/zwave-js-ui";
      description = lib.mdDoc ''
        The data directory for zwave-js-ui.
      '';
    };
  };

  # TODO: add open firewall
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
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/zwave-js-ui";
        StateDirectory = "zwave-js-ui";
        WorkingDirectory = "%S/${stateDir}";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
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
