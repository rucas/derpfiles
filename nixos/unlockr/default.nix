{ pkgs, CONF, ... }:
let
  torRc = pkgs.writeText "tor.rc" ''
    DataDirectory /etc/tor
    SOCKSPort 127.0.0.1:9050 IsolateDestAddr
    SOCKSPort 127.0.0.1:9063
    HiddenServiceDir /etc/tor/onion/bootup
    HiddenServicePort 22 127.0.0.1:22
  '';
in
{
  boot = {
    kernelParams = [ "ip=dhcp" ];
    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = CONF.hosts.rucaslab.trusted;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
      };
      secrets = {
        "/etc/tor/onion/bootup" = "/home/lucas/tor/onion";
      };
      systemd = {
        users.root.shell = "/bin/systemd-tty-ask-password-agent";
        storePaths = [
          "${pkgs.haveged}/bin/haveged"
          "${pkgs.tor}/bin/tor"
          "${pkgs.coreutils}/bin/chmod"
          torRc
        ];
        services = {
          initrd-haveged = {
            description = "Entropy harvesting daemon (initrd)";
            wantedBy = [ "initrd.target" ];
            after = [ "systemd-modules-load.service" ];
            before = [
              "initrd-tor.service"
              "cryptsetup.target"
            ];
            conflicts = [ "initrd-switch-root.target" ];
            unitConfig.DefaultDependencies = false;
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.haveged}/bin/haveged -F";
            };
          };
          initrd-tor = {
            description = "Tor hidden service (initrd)";
            wantedBy = [ "initrd.target" ];
            requires = [
              "network-online.target"
              "initrd-haveged.service"
            ];
            after = [
              "network-online.target"
              "initrd-haveged.service"
            ];
            before = [ "cryptsetup.target" ];
            conflicts = [ "initrd-switch-root.target" ];
            unitConfig.DefaultDependencies = false;
            serviceConfig = {
              Type = "simple";
              ExecStartPre = "${pkgs.coreutils}/bin/chmod -R 700 /etc/tor";
              ExecStart = "${pkgs.tor}/bin/tor -f ${torRc}";
              Restart = "on-failure";
              RestartSec = "5s";
            };
          };
        };
      };
    };
  };
}
