{ CONF, ... }: {
  services.home-assistant.config = {
    sonos = { media_player = { hosts = [ CONF.hosts.sonos.sonos_move_ip ]; }; };
  };
}

