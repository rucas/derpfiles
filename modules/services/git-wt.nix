{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.git-wt;
  inherit (pkgs.stdenv) isDarwin isLinux;

  homeDir = config.home.homeDirectory;

  logDir = if isDarwin then "${homeDir}/Library/Logs" else "${homeDir}/.local/state/git-wt";

  cacheDir = "${homeDir}/.cache/git-wt/pr";

  syncCommand = [
    "${pkgs.git-wt}/bin/git-wt"
    "pr-sync"
  ]
  ++ concatMap (
    repo:
    [
      "--repo"
      repo.path
    ]
    ++ concatMap (check: [
      "--ignore-check"
      check
    ]) repo.ignoreChecks
  ) cfg.repos
  ++ optionals (cfg.configFile != null) [
    "--config"
    cfg.configFile
  ];
in
{
  options.programs.git-wt = {
    enable = mkEnableOption "git wt worktree manager with background PR-status refresh";

    repos = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "Absolute path of the git repository to refresh.";
            };

            ignoreChecks = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [
                "afrm-rulez"
                "Deploy Lock"
                "OK to Board"
              ];
              description = ''
                Status check names to exclude when deciding this repo's PR BROKEN/CI state.
                Use this for gating checks (deploy locks, approval gates) that stay
                pending until a human acts, so they don't make tests look "still running".
              '';
            };
          };
        }
      );
      default = [ ];
      example = [ { path = "/Users/lucas.rondenet/Code/derpfiles"; } ];
      description = "Git repositories whose worktree PR status should be refreshed.";
    };

    intervalSeconds = mkOption {
      type = types.int;
      default = 60;
      description = "How often (in seconds) to refresh cached PR status.";
    };

    configFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/usr/local/var/opnix/secrets/git-wt/config";
      description = ''
        Path to a JSON file of additional repos to refresh, shaped like
        [ { "path": "...", "ignoreChecks": [ "..." ] } ]. Read at runtime, so it can
        point at an opnix/secret-managed file and keep private repo paths and check
        names out of the (public) Nix configuration.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ pkgs.git-wt ];

      # Keep the interactive `git wt ls` cache path in lockstep with the background job.
      home.sessionVariables.WT_PR_CACHE_DIR = cacheDir;
    }

    (mkIf isDarwin {
      launchd.agents.git-wt-pr-sync = {
        enable = true;
        config = {
          Label = "com.rucas.git-wt.pr-sync";
          ProgramArguments = syncCommand;
          RunAtLoad = true;
          StartInterval = cfg.intervalSeconds;
          StandardOutPath = "${logDir}/git-wt-pr-sync-stdout.log";
          StandardErrorPath = "${logDir}/git-wt-pr-sync-stderr.log";
          EnvironmentVariables = {
            WT_PR_CACHE_DIR = cacheDir;
          };
        };
      };
    })

    (mkIf isLinux {
      systemd.user.services.git-wt-pr-sync = {
        Unit.Description = "Refresh cached PR status for git wt ls";
        Service = {
          Type = "oneshot";
          ExecStart = escapeShellArgs syncCommand;
          Environment = [ "WT_PR_CACHE_DIR=${cacheDir}" ];
        };
      };

      systemd.user.timers.git-wt-pr-sync = {
        Unit.Description = "Periodic PR-status refresh for git wt ls";
        Timer = {
          OnBootSec = "1min";
          OnUnitActiveSec = "${toString cfg.intervalSeconds}s";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    })
  ]);
}
