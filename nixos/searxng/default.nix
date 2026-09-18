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
      # server starts, so the keys themselves never enter the Nix store.
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

        # query.wikidata.org enforces the Wikimedia User-Agent policy and 403s
        # the bare "SearXNG/<version>" default, which killed the wikidata engine
        # at init on every start. A URL-form contact is what the policy wants;
        # it satisfies the check without putting an email in a header that goes
        # to every engine. The host need not be publicly reachable.
        outgoing.useragent_suffix = "(+https://search.rucaslab.com)";

        search = {
          # Upstream ships html only. Open WebUI's searxng loader requests
          # format=json and gets a 403 without this.
          formats = [
            "html"
            "json"
          ];
          # Its own subsystem in searx/autocomplete.py, unrelated to the
          # duckduckgo engine disabled below, and only used by the web UI.
          autocomplete = "duckduckgo";
          safe_search = 0;
        };

        # Merged by name into the upstream engine list that use_default_settings
        # pulls in.
        #
        # Everything disabled here fails closed on bot detection from a
        # residential IP: the scrape endpoints fingerprint the HTTP client, not
        # just the address, so there is no configuration that recovers them.
        # Each one left enabled would still be queried on every Open WebUI
        # search and still have to time out before results are returned.
        # Measured failure rates come from /stats/errors.
        engines = [
          # 429 TooManyRequests, 45% of requests. Superseded by braveapi below.
          {
            name = "brave";
            disabled = true;
          }
          # CAPTCHA, 90%.
          {
            name = "duckduckgo";
            disabled = true;
          }
          # CAPTCHA, 65%.
          {
            name = "startpage";
            disabled = true;
          }
          {
            name = "startpage images";
            disabled = true;
          }
          # The same index as the scraped engine, over the official API.
          # Upstream ships this entry as `inactive`, which drops it before
          # registration, so it has to be flipped for the engine to exist at all.
          {
            name = "braveapi";
            inactive = false;
            shortcut = "brapi";
            # Substituted from environmentFile, same as secret_key above.
            api_key = "$BRAVE_API_KEY";
            # The free tier allows 1 req/s and 2000/month. Open WebUI reads the
            # top handful of results, so one page per query stays inside that.
            results_per_page = 20;
          }
        ];
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
