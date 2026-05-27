{ config, pkgs, ... }:
{
  services.prometheus = {
    enable = true;
    port = 9001;

    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "unpoller";
        scrape_interval = "30s";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.unpoller.port}"
            ];
          }
        ];
      }
      {
        job_name = "blackbox-golinks";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [
              "https://home.rucaslab.com"
              "https://grafana.rucaslab.com"
              "https://budget.rucaslab.com"
              "https://wiki.rucaslab.com"
              "https://status.rucaslab.com"
              "https://docs.rucaslab.com"
              "https://adguard.rucaslab.com"
              "https://auth.rucaslab.com"
              "https://esphome.rucaslab.com"
              "https://zigbee.rucaslab.com"
              "https://zwave.rucaslab.com"
              "https://changedetection.rucaslab.com"
              "https://unifi.rucaslab.com"
              "https://windmill.rucaslab.com"
              "https://ollama.rucaslab.com"
              "https://ntfy.rucaslab.com"
              "https://lldap.rucaslab.com"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
          }
        ];
      }
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };

      blackbox = {
        enable = true;
        port = 9115;
        configFile = pkgs.writeText "blackbox.yaml" ''
          modules:
            http_2xx:
              prober: http
              timeout: 5s
              http:
                valid_status_codes: []
                follow_redirects: true
        '';
      };

      unpoller = {
        enable = true;
        controllers = [
          {
            url = "https://192.168.1.1";
            user = "unpoller";
            pass = config.age.secrets.unpoller.path;
            verify_ssl = false;
            sites = "all";
            save_sites = true;
            save_dpi = false;
          }
        ];
      };
    };
  };
}
