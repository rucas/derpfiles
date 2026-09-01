{
  pkgs,
  config,
  lib,
  ...
}:
#
# Open WebUI's web loader (WEB_LOADER_ENGINE=firecrawl). crw exposes a
# Firecrawl-compatible /v2/scrape that returns ready-made markdown, which keeps
# HTML-to-text conversion out of the uvicorn workers — the same reason content
# extraction already goes to Tika rather than running in-process.
#
# Its renderer tier is camofox-browser: a Node server wrapping Camoufox, the
# anti-detect Firefox. That one runs as a container because Camoufox is a
# patched Firefox fetched at image build time (`npx camoufox-js fetch`) and is
# not packaged in nixpkgs.
let
  # 3001 is uptime-kuma (its module default, not a literal anywhere in this repo)
  port = 3002;
  camofoxPort = 9377;

  settings = (pkgs.formats.toml { }).generate "crw.toml" {
    server = {
      host = "127.0.0.1";
      inherit port;
      request_timeout_secs = 120;
      rate_limit_rps = 10;
    };

    renderer = {
      mode = "camofox";
      page_timeout_ms = 30000;
      # Each slot holds a Firefox context. rucaslab is a 4-core i7-1165G7 also
      # running Ollama inference, so 2 rather than the upstream 4.
      pool_size = 2;
      camofox.base_url = "http://127.0.0.1:${toString camofoxPort}";
    };

    crawler = {
      max_concurrency = 4;
      requests_per_second = 5.0;
      respect_robots_txt = true;
    };

    # /v1/search needs the camofox renderer, which is configured, but Open WebUI
    # gets its results from SearXNG — this only serves direct API callers.
    search.enabled = true;

    document = {
      enabled = true;
      # Search results are untrusted input, so parse each PDF in a child process
      # with its own address-space limit.
      sandbox = true;
    };
  };
in
{
  # AppConfig::load feeds $CRW_CONFIG to config::File::with_name, which appends
  # the extension itself — hence the extensionless path below.
  environment.etc."crw/config.toml".source = settings;

  systemd = {
    services = {
      crw = {
        description = "CRW web scraper API";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network-online.target"
          "podman-camofox.service"
        ];
        wants = [ "network-online.target" ];

        environment = {
          CRW_CONFIG = "/etc/crw/config";
          RUST_LOG = "info";
        };

        serviceConfig = {
          ExecStart = lib.getExe pkgs.crw;
          # CRW_RENDERER__CAMOFOX__API_KEY — crw maps CRW_ + "__"-separated
          # paths onto the config tree, so the token stays out of the store.
          EnvironmentFile = config.age.secrets.crw_env.path;
          DynamicUser = true;
          Restart = "on-failure";
          RestartSec = 5;

          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          NoNewPrivileges = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
        };
      };

    };

    tmpfiles.rules = [
      # The image runs as uid 1000 (node) and writes profiles and cookies here.
      "d /var/lib/camofox 0750 1000 1000 -"
    ];
  };

  virtualisation = {
    podman = {
      enable = true;
      autoPrune.enable = true;
      # aardvark-dns cannot bind 10.88.0.1:53 because AdGuard Home holds the
      # *:53 wildcard, so podman's default network fails to come up. Nothing
      # here resolves container names — containers inherit the host's resolvers
      # through /etc/resolv.conf — so turn DNS off for it. This lands in
      # /etc/containers/networks/podman.json, which `podman system prune`
      # cannot delete (a user-created network can be, and was).
      #
      # mkForce overrides services.changedetection-io, which asserts this
      # unconditionally for its chrome/playwright sidecars. Neither is enabled
      # here — camofox is the only container on this host — and those sidecars
      # are reached on published loopback ports rather than by container name.
      defaultNetwork.settings.dns_enabled = lib.mkForce false;
    };

    oci-containers = {
      backend = "podman";
      containers.camofox = {
        # Pinned by digest, not tag: tags are mutable and this image is outside
        # the flake's correctness gate. 2.4.6 is what crw v1.2.0 tests against.
        image = "ghcr.io/redf0x1/camofox-browser:2.4.6@sha256:41e79fb61d50f0a8292b2a51c81ebcb0a2be24d89e9eac970edd12613006ced7";
        ports = [ "127.0.0.1:${toString camofoxPort}:${toString camofoxPort}" ];

        environment = {
          # Must be non-loopback for the published port to reach it inside the
          # container's netns; `auto` then demands the API key below.
          CAMOFOX_HOST = "0.0.0.0";
          CAMOFOX_PORT = toString camofoxPort;
          CAMOFOX_AUTH_MODE = "auto";
          # NOTE: deliberately NOT setting CAMOFOX_ALLOW_PRIVATE_NETWORK. On a
          # non-loopback bind camofox blocks navigation to loopback/private/
          # link-local targets, which is the only thing stopping a hostile search
          # result from making Camoufox fetch Home Assistant, AdGuard or Authelia
          # from inside the network.
        };
        # CAMOFOX_API_KEY, matching crw_env.age
        environmentFiles = [ config.age.secrets.camofox_env.path ];

        volumes = [ "/var/lib/camofox:/home/node/.camofox" ];
        # Hold the unit "activating" until the image's own /health check passes,
        # so crw's ordering on this unit means the browser is actually ready.
        podman.sdnotify = "healthy";
        extraOptions = [
          # Firefox needs a real shared-memory segment; the 64M default crashes tabs.
          "--shm-size=1g"
          "--pids-limit=512"
        ];
      };
    };
  };
}
