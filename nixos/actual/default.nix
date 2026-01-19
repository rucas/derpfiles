{ ... }:
let port = 4323;
in {
  services = {
    caddy = {
      virtualHosts = {
        "budget.rucaslab.com" = {
          extraConfig = ''
            # import auth
            import https-proxy :${toString port}

            # NOTE: this happens after success forward auth
            # header X-Actual-Password {$ACTUAL_PASSWORD}
            # encode zstd gzip
            # tls {
            #   dns cloudflare {$CLOUDFLARE_API_TOKEN}
            # }
            # reverse_proxy :${toString port} {
            #   header_up X-Actual-Password {$ACTUAL_PASSWORD}
            # }
          '';
        };
      };
    };
    actual = {
      enable = true;
      settings = { port = port; };
    };
  };
  systemd.services.actual.environment = {
    # ACTUAL_LOGIN_METHOD = "header";
    ACTUAL_ALLOWED_LOGIN_METHODS = "password,header";
    # ACTUAL_DISABLE_LOGIN_REDIRECT = "true";
  };
}
