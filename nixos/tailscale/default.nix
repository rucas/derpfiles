{ config, ... }: {
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-dns=false" "--advertise-routes=192.168.0.0/24" ];
    authKeyFile = config.age.secrets.tailscale.path;
  };

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # NOTE: we set use adguard as DNS
  networking.nameservers = [ "edns0" ];
}
