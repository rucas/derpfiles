{ pkgs, config, ... }:
let
  workspace = "rucaslab";

  # The scripts depend on @actual-app/api -> better-sqlite3, a Node native addon
  # that does not run under Windmill's bundled Bun runtime. Windmill's //nodejs
  # escape hatch is Enterprise-only, so the scripts are deployed as bash and run
  # with the real `node` binary. Dependencies are pre-built once (with
  # better-sqlite3 compiled from source) and symlinked next to each script's
  # source as its node_modules; ESM ignores NODE_PATH, so adjacency is required.
  # The .ts/.mjs sources stay the single source of truth and run identically in
  # the flake devshell and in Windmill.
  withNodeModules =
    name: files:
    pkgs.runCommand name { } ''
      mkdir -p $out
      ${pkgs.lib.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (dest: src: "cp ${src} $out/${dest}") files
      )}
      ln -s ${pkgs.actual-budget-api}/lib/node_modules $out/node_modules
    '';

  categorizerApp = withNodeModules "categorizer-app" {
    "main.ts" = ./scripts/actual_budget_categorizer/main.ts;
    "run.ts" = ./scripts/actual_budget_categorizer/run.ts;
  };

  syncApp = withNodeModules "sync-app" {
    "sync.mjs" = ./scripts/actual_budget_sync/sync.mjs;
  };

  syncScripts = pkgs.runCommand "windmill-scripts" { } ''
    cp -r ${./scripts} $out
  '';
in
{
  services = {
    windmill = {
      enable = true;
      serverPort = 8001;
      baseUrl = "https://windmill.rucaslab.com";
      database = {
        createLocally = true;
        name = "windmill";
        user = "windmill";
      };
    };
    caddy.virtualHosts."windmill.rucaslab.com" = {
      extraConfig = ''
        import auth
        import https-proxy :8001
      '';
    };
  };

  # Store paths to the script "apps" (source + node_modules symlink). Windmill
  # runs jobs with a sanitized env, so these names must also be listed in
  # WHITELIST_ENVS on the worker (see hosts/rucaslab/configuration.nix).
  systemd.services.windmill-worker.environment = {
    CATEGORIZER_APP = categorizerApp;
    SYNC_APP = syncApp;
  };

  systemd.services.windmill-sync = {
    description = "Sync Windmill scripts from git repo";
    after = [ "windmill-server.service" ];
    requires = [ "windmill-server.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ syncScripts ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "windmill";
      Group = "windmill";
    };

    path = [ pkgs.curl ];

    script = ''
      until curl -sf http://localhost:8001/api/version > /dev/null 2>&1; do
        sleep 2
      done
      ${pkgs.windmill-sync}/bin/windmill-sync ${syncScripts} http://localhost:8001 ${config.services.onepassword-secrets.secrets.windmillApiToken.path} ${workspace}
    '';
  };
}
