{ config, ... }: {
  services = {
    golink = {
      enable = true;
      tailscaleAuthKeyFile = config.age.secrets.tailscale_golink.path;
    };
  };
}
