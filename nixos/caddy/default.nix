{ pkgs, ... }: {
  services = {
    caddy = {
      enable = true;
      package = pkgs.callPackage ../../pkgs/zaddy {
        plugins = [ "github.com/caddy-dns/cloudflare" ];
      };
      virtualHosts = {
        ":8888" = {
          extraConfig = ''
            reverse_proxy :3000
          '';
        };
        #NOTE: http:// works
        "http://adguard.home" = {
          extraConfig = ''
            reverse_proxy :3000
          '';
        };
      };
    };
  };
  systemd.services.caddy = {
    serviceConfig = {
      # Required to use ports < 1024
      AmbientCapabilities = "cap_net_bind_service";
      CapabilityBoundingSet = "cap_net_bind_service";
      # EnvironmentFile = config.age.secrets."caddy-environment-file".path;
      TimeoutStartSec = "5m";
    };
  };
}
