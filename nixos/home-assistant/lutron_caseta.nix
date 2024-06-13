{ CONF, config, ... }: {
  services.home-assistant.config = {
    lutron_caseta = {
      host = CONF.hosts.lutron.internal_ip;
      keyfile = config.age.secrets.lutron.path;
      certfile = "/etc/lutron/client.crt";
      ca_certs = "/etc/lutron/ca.crt";
    };
  };
}
