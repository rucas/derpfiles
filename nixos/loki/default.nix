{ ... }: {
  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3030;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore = { store = "inmemory"; };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        # NOTE: Any chunk not receiving new logs in this time will be flushed
        chunk_idle_period = "1h";
        # NOTE: All chunks will be flushed when they hit this age, default is 1h
        max_chunk_age = "1h";
        # NOTE: Loki will attempt to build chunks up to 1.5MB, flushing first if
        # chunk_idle_period or max_chunk_age is reached first
        chunk_target_size = 1048576;
        # NOTE: Must be greater than index read cache TTL if using an index
        # cache (Default index read cache TTL is 5m)
        chunk_retain_period = "30s";
      };

      schema_config.configs = [{
        from = "2020-10-24";
        store = "boltdb-shipper";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];

      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          # NOTE: Can be increased for faster performance over longer query
          # periods, uses more disk space
          cache_ttl = "24h";
        };

        filesystem = { directory = "/var/lib/loki/chunks"; };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        allow_structured_metadata = false;
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor.working_directory = "/var/lib/loki/boltdb-shipper-compactor";

    };
  };
}
