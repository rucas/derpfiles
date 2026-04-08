{ config, ... }:
let
  lokiPort = toString config.services.loki.configuration.server.http_listen_port;
in
{
  services.alloy.enable = true;

  environment.etc."alloy/config.alloy".text = ''
    loki.source.journal "systemd" {
      forward_to    = [loki.write.local.receiver]
      max_age       = "12h"
      labels        = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
      relabel_rules = loki.relabel.journal.rules
    }

    loki.relabel "journal" {
      forward_to = []
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:${lokiPort}/loki/api/v1/push"
      }
    }
  '';
}
