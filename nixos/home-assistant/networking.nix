{ ... }: {
  networking.firewall = {
    # NOTE: sonos discovery
    allowedTCPPortRanges = [{
      from = 1400;
      to = 1500;
    }];
    # NOTE: homekit discovery
    allowedUDPPorts = [ 5353 ];
  };
}
