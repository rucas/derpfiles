{
  pkgs,
  config,
  lib,
  ...
}:
#
# Open WebUI tuned per the upstream "High Scale / Enterprise" profile:
# https://docs.openwebui.com/troubleshooting/performance
#
# The three mandatory swaps away from the defaults are PostgreSQL instead of
# SQLite, pgvector instead of ChromaDB's local mode (its SQLite backend crashes
# under multi-worker access), and external embedding + content extraction
# (SentenceTransformers and pypdf are the documented memory hogs at scale).
let
  port = 8081;
  # rucaslab is an i7-1165G7: 4 physical cores / 8 threads. One worker per
  # physical core leaves the SMT siblings for Ollama inference, Tika and Postgres.
  workers = 4;
  redisUrl = "redis://127.0.0.1:6380/0";
  # postgres extra = pgvector + psycopg2-binary
  package = pkgs.open-webui.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ pkgs.open-webui.optional-dependencies.postgres;
  });
in
{
  services = {
    open-webui = {
      inherit package port;
      enable = true;
      environment = {
        # Admin settings normally live in the database after first boot, which
        # would make every later edit to this file a silent no-op. Nix is the
        # source of truth instead. Workspace content (models, prompts,
        # knowledge, chats) lives in its own tables and is unaffected.
        ENABLE_PERSISTENT_CONFIG = "False";

        WEBUI_URL = "https://ai.rucaslab.com";

        # Local inference
        ENABLE_OLLAMA_API = "True";
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";

        # Frontier models through OpenRouter's OpenAI-compatible endpoint.
        # OPENAI_API_KEYS comes from open_webui_openrouter_env.age.
        ENABLE_OPENAI_API = "True";
        OPENAI_API_BASE_URLS = "https://openrouter.ai/api/v1";
        # Title/tag/query generation runs on every message — keep it off both
        # the local GPU and the expensive models
        TASK_MODEL_EXTERNAL = "google/gemini-3.5-flash-lite";

        # Off upstream by default. These are persistent-config settings, so with
        # ENABLE_PERSISTENT_CONFIG=False the admin UI toggles would not survive a
        # restart — they have to be set here.
        ENABLE_SUBAGENTS = "True";
        # Background subagents pay off against OpenRouter, where fan-out is
        # network-bound and genuinely parallel; against the local model they just
        # queue behind OLLAMA_NUM_PARALLEL. Note they run without external tool
        # servers and without the pyodide code interpreter — web search, native
        # tools and skills still work.
        SUBAGENTS_BACKGROUND_ENABLED = "True";
        # These caps live in module-level state, so each of the 4 uvicorn workers
        # enforces its own. 5 per worker lands the real ceiling near 20 rather
        # than the 80 the upstream default of 20 would allow.
        SUBAGENTS_MAX_CONCURRENT = "5";
        SUBAGENTS_MAX_ASYNC = "5";

        # Authelia is the only way in — no local accounts, no signup form
        ENABLE_LOGIN_FORM = "False";
        ENABLE_SIGNUP = "False";
        ENABLE_OAUTH_SIGNUP = "True";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_CLIENT_ID = "open-webui";
        OPENID_PROVIDER_URL = "https://auth.rucaslab.com/.well-known/openid-configuration";
        OPENID_REDIRECT_URI = "https://ai.rucaslab.com/oauth/oidc/callback";
        OAUTH_SCOPES = "openid email profile groups";
        OAUTH_USERNAME_CLAIM = "preferred_username";
        OAUTH_TOKEN_ENDPOINT_AUTH_METHOD = "client_secret_basic";
        OAUTH_CODE_CHALLENGE_METHOD = "S256";

        # Membership is driven by the LLDAP groups Authelia puts in the groups claim
        ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
        OAUTH_ROLES_CLAIM = "groups";
        OAUTH_ALLOWED_ROLES = "openwebui,openwebui-admin";
        OAUTH_ADMIN_ROLES = "openwebui-admin";

        # Postgres over the unix socket via peer auth. The +psycopg driver is
        # explicit because a bare postgresql:// URL resolves to psycopg2 for the
        # sync engine, and psycopg v3 is what ships in the base closure.
        DATABASE_URL = "postgresql+psycopg://open-webui@/open-webui?host=/run/postgresql";
        DATABASE_POOL_SIZE = "15";
        DATABASE_POOL_MAX_OVERFLOW = "20";
        DATABASE_POOL_TIMEOUT = "30";
        DATABASE_POOL_RECYCLE = "3600";

        VECTOR_DB = "pgvector";

        REDIS_URL = redisUrl;
        WEBSOCKET_MANAGER = "redis";
        WEBSOCKET_REDIS_URL = redisUrl;
        ENABLE_WEBSOCKET_SUPPORT = "True";

        UVICORN_WORKERS = toString workers;
        THREAD_POOL_SIZE = "2000";

        RAG_EMBEDDING_ENGINE = "ollama";
        RAG_OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        RAG_EMBEDDING_MODEL = "nomic-embed-text";

        CONTENT_EXTRACTION_ENGINE = "tika";
        TIKA_SERVER_URL = "http://127.0.0.1:9998";

        ENABLE_REALTIME_CHAT_SAVE = "False";
        CHAT_RESPONSE_STREAM_DELTA_CHUNK_SIZE = "7";
        ENABLE_BASE_MODELS_CACHE = "True";
        MODELS_CACHE_TTL = "300";
        ENABLE_QUERIES_CACHE = "True";
        ENABLE_ORJSON = "True";
        # Caddy already does `encode zstd gzip` in front of this
        ENABLE_COMPRESSION_MIDDLEWARE = "False";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };

    redis.servers.open-webui = {
      enable = true;
      bind = "127.0.0.1";
      port = 6380;
      maxclients = 10000;
      settings = {
        # Reap idle connections so they don't accumulate until Redis OOMs
        timeout = 1800;
        # Socket.IO publishes multi-MB payloads for large streams; the default
        # pubsub buffer limit disconnects those clients mid-stream
        client-output-buffer-limit = [
          "normal 0 0 0"
          "replica 268435456 67108864 60"
          "pubsub 1073741824 268435456 180"
        ];
      };
    };

    tika = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9998;
    };

    caddy.virtualHosts."ai.rucaslab.com" = {
      extraConfig = ''
        import https-proxy :${toString port}
      '';
    };
  };

  users = {
    users.open-webui = {
      isSystemUser = true;
      group = "open-webui";
    };
    groups.open-webui = { };
  };

  systemd.services = {
    # pgvector has to exist in the database before Open WebUI's migrations run
    open-webui-pgvector = {
      description = "Create the pgvector extension for Open WebUI";
      requiredBy = [ "open-webui.service" ];
      before = [ "open-webui.service" ];
      # postgresql-setup is what actually runs ensureDatabases, so the database
      # only exists once it has finished
      after = [ "postgresql-setup.service" ];
      requires = [ "postgresql-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
        ExecStart = ''
          ${config.services.postgresql.package}/bin/psql -d open-webui -c "CREATE EXTENSION IF NOT EXISTS vector"
        '';
      };
    };

    open-webui = {
      after = [
        "ollama.service"
        "postgresql-setup.service"
        "redis-open-webui.service"
        "tika.service"
      ];
      wants = [
        "ollama.service"
        "tika.service"
      ];
      requires = [
        "postgresql-setup.service"
        "redis-open-webui.service"
      ];
      # Peer auth over the postgres socket needs a stable user, which rules out
      # the upstream module's DynamicUser
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "open-webui";
        Group = "open-webui";
        # The module derives this from services.open-webui.environmentFile, which
        # only takes one path — mkForce so both secrets get loaded
        EnvironmentFile = lib.mkForce [
          # OAUTH_CLIENT_SECRET, WEBUI_SECRET_KEY
          config.age.secrets.open_webui_env.path
          # OPENAI_API_KEYS
          config.age.secrets.open_webui_openrouter_env.path
        ];
      };
    };
  };
}
