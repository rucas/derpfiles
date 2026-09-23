{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    # Home Assistant dropped support for PostgreSQL < 15; 17 is the current
    # long-support major that every service on this host is validated against.
    package = pkgs.postgresql_17;
    # The datapool/postgresql dataset mounts at /data/postgresql, so each major
    # gets its own directory underneath and an upgrade is a dataDir change.
    dataDir = "/data/postgresql/17";
    # Open WebUI runs 4 uvicorn workers, each with its own pool of
    # DATABASE_POOL_SIZE + DATABASE_POOL_MAX_OVERFLOW (15 + 20) connections, so
    # it alone can reach 140. The default of 100 is not enough to share.
    settings.max_connections = 300;
    # pgvector backs Open WebUI's RAG store — ChromaDB's local mode is not
    # safe across multiple uvicorn workers
    extensions = ps: [ ps.pgvector ];
    ensureDatabases = [
      "authelia-rucaslab"
      "hass"
      "lldap"
      "outline"
      "open-webui"
    ];
    ensureUsers = [
      {
        name = "authelia-rucaslab";
        ensureDBOwnership = true;
      }
      {
        name = "hass";
        ensureDBOwnership = true;
      }
      {
        name = "lldap";
        ensureDBOwnership = true;
      }
      {
        name = "outline";
        ensureDBOwnership = true;
      }
      {
        name = "open-webui";
        ensureDBOwnership = true;
      }
    ];
  };
}
