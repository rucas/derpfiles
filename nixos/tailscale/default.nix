{ config, ... }: {
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-dns=false"
      "--advertise-routes=192.168.0.0/24,192.168.1.0/24"
    ];
    authKeyFile = config.age.secrets.tailscale.path;
  };

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

}
