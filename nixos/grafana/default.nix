{ pkgs, config, ... }:
{
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString config.services.prometheus.port}";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Node";
          type = "file";
          url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
          options.path = pkgs.fetchFromGitHub {
            owner = "rfmoz";
            repo = "grafana-dashboards";
            rev = "cad8539";
            hash = "sha256-9BYujV2xXRRDvNI4sjimZEB4Z2TY/0WhwJRh5P122rs=";
          };
        }
        {
          name = "UniFi";
          type = "file";
          options.path =
            let
              src = pkgs.fetchFromGitHub {
                owner = "unpoller";
                repo = "dashboards";
                rev = "0fe7c05";
                hash = "sha256-XLhmOoeTBhKxYs8tLeWy3ng7rLzaCjt0Dhn7pAuL0Vk=";
              };
            in
            pkgs.runCommand "unpoller-prometheus-dashboards" { nativeBuildInputs = [ pkgs.jq ]; } ''
              mkdir -p $out
              for f in ${src}/v2.0.0/*Prometheus*.json; do
                jq 'del(.__inputs, .__requires) | walk(if type == "object" and .datasource?.uid? == "''${DS_PROMETHEUS}" then .datasource = null else . end)' "$f" \
                  > "$out/$(basename "$f")"
              done
            '';
        }
      ];
    };
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 2342;
        domain = "grafana.rucaslab.com";
        root_url = "https://grafana.rucaslab.com";
      };
      security = {
        secret_key = "$__file{${config.age.secrets.grafana.path}}";
        admin_password = "$__file{${config.age.secrets.grafana_admin_password.path}}";
      };
      paths = {
        data = "/data/grafana";
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";
        client_id = "grafana";
        client_secret = "$__file{${config.age.secrets.grafana_oidc_client_secret.path}}";
        scopes = "openid profile email groups";
        auth_url = "https://auth.rucaslab.com/api/oidc/authorization";
        token_url = "https://auth.rucaslab.com/api/oidc/token";
        api_url = "https://auth.rucaslab.com/api/oidc/userinfo";
        login_attribute_path = "preferred_username";
        name_attribute_path = "name";
        use_refresh_token = true;
        auto_login = false;
        allow_sign_up = true;
      };
    };
  };
}
