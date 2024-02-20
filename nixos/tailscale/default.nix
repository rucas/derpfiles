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

  # NOTE: we set use adguard as DNS
  # make sure to set in tailscale app settings.
  # https://akashrajpurohit.com/blog/adguard-home-tailscale-erase-ads-on-the-go/
  networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    extraConfig = ''
      DNSOverTLS=yes
    '';
  };
}
