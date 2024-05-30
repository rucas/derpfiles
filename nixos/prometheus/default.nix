{ config, ... }: {
  services.prometheus = {
    enable = true;
    port = 9001;

    scrapeConfigs = [{
      job_name = "node";
      scrape_interval = "15s";
      static_configs = [{
        targets = [
          "localhost:${toString config.services.prometheus.exporters.node.port}"
        ];
      }];
    }];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };
}
