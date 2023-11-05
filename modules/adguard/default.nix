{ ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 3000 ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = false;
      openFirewall = true;
    };
  };
}
