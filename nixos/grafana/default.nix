{ pkgs, config, ... }: {
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://localhost:${toString config.services.prometheus.port}";
        isDefault = true;
      }];
      dashboards.settings.providers = [{
        name = "Node";
        type = "file";
        url =
          "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
        options.path = pkgs.fetchFromGitHub {
          owner = "rfmoz";
          repo = "grafana-dashboards";
          rev = "cad8539";
          hash = "sha256-9BYujV2xXRRDvNI4sjimZEB4Z2TY/0WhwJRh5P122rs=";
        };
      }];
    };
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 2342;
        domain = "grafana.rucaslab.com";
      };
    };
  };
}
