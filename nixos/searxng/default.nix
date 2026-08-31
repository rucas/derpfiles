{ config, ... }:
#
# Search backend for Open WebUI (WEB_SEARCH_ENGINE=searxng). Open WebUI reaches
# it over loopback; the Caddy vhost exists only so the UI is browsable for
# debugging queries by hand.
let
  port = 8082;
in
{
  services = {
    searx = {
      enable = true;
      # searx-init envsubst's this over settings.yml into /run/searx before the
      # server starts, so the key itself never enters the Nix store.
      environmentFile = config.age.secrets.searx_env.path;

      settings = {
        general.instance_name = "rucaslab";

        server = {
          inherit port;
          bind_address = "127.0.0.1";
          # Substituted from environmentFile. SearXNG refuses to start with the
          # upstream "ultrasecretkey" placeholder that use_default_settings pulls in.
          secret_key = "$SEARX_SECRET_KEY";
          # Loopback-only with a single consumer, so the limiter would only ever
          # rate-limit Open WebUI itself.
          limiter = false;
        };

        search = {
          # Upstream ships html only. Open WebUI's searxng loader requests
          # format=json and gets a 403 without this.
          formats = [
            "html"
            "json"
          ];
          autocomplete = "duckduckgo";
          safe_search = 0;
        };
      };
    };

    caddy.virtualHosts."search.rucaslab.com" = {
      extraConfig = ''
        import auth
        import https-proxy :${toString port}
      '';
    };
  };
}
