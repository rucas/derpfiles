{ ... }: {
  services.glance = {
    enable = true;
    settings = {
      server = { port = 4321; };
      pages = [{
        name = "Startpage";
        width = "slim";
        hide-desktop-navigation = true;
        center-vertically = true;
        columns = [{
          size = "full";
          widgets = [
            {
              type = "search";
              autfocus = true;
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Apps";
              sites = [
                {
                  title = "AdGuard Home";
                  url = "https://adguard.rucaslab.com";
                  icon = "si:adguard";
                }
                {
                  title = "Home Assistant";
                  url = "https://home.rucaslab.com";
                  icon = "si:homeassistant";
                }
                {
                  title = "Paperless-ngx";
                  url = "https://paperless.rucaslab.com";
                  icon = "si:paperlessngx";
                }
                {
                  title = "zigbee2mqtt";
                  url = "https://zigbee.rucaslab.com";
                  icon = "si:zigbee2mqtt";
                }
                {
                  title = "changedetection.io";
                  url = "https://changedetection.rucaslab.com";
                  icon = "si:rss";
                }
                {
                  title = "Grafana";
                  url = "https://grafana.rucaslab.com";
                  icon = "si:grafana";
                }
              ];
            }
          ];
        }];

      }];
    };
  };
}
