{ CONF, config, ... }: {
  services.zwave-js-ui-rucas = {
    enable = true;
    behindProxy = true;
    settings = {
      zwave = { port = CONF.hosts.rucaslab.zwave.device; };
      ui = {
        darkMode = true;
        navTabs = true;
      };
    };
    networkKeyFile = config.age.secrets.zwave-js-ui.path;
  };
}
