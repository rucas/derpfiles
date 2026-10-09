{ CONF, config, ... }:
{
  services.zwave-js-ui-rucas = {
    enable = true;
    behindProxy = true;
    settings = {
      zwave = {
        port = CONF.hosts.rucaslab.zwave.device;
        rf = {
          region = 9; # RFRegion["USA (Long Range)"]
          autoPowerlevels = false; # "auto" only fires on a region change
          txPower = {
            powerlevel = -1; # ZWA-2, US
            measured0dBm = 0; # hardware calibration, do not change
          };
          maxLongRangePowerlevel = 20; # ZWA-2, US
        };
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
