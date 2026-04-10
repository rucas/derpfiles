{ config, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "87bf0875-3104-4d3a-9003-348f6fdbf14a" = {
        credentialsFile = config.age.secrets.cloudflared_tunnel_credentials.path;
        default = "http_status:404";
      };
    };
  };
}
