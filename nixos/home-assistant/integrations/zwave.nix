{ CONF, config, ... }:
{
  services.zwave-js-ui-rucas = {
    enable = true;
    behindProxy = true;
    settings = {
      zwave = {
        port = CONF.hosts.rucaslab.zwave.device;
        rf.region = 9; # RFRegion["USA (Long Range)"]
      };
      backup = {
        storeBackup = true;
        nvmBackup = true;
        nvmBackupOnEvent = true;
      };
      ui = {
        darkMode = true;
        navTabs = true;
      };
    };
    networkKeyFile = config.age.secrets.zwave-js-ui.path;
  };
}
