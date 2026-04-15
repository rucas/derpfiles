{
  pkgs,
  lib,
  config,
  ...
}:
let
  scannerSshdConfig = pkgs.writeText "sshd_config_scanner" ''
    Port 2222
    ListenAddress 192.168.1.136

    HostKey /etc/ssh/ssh_host_rsa_key_scanner
    HostKeyAlgorithms ssh-rsa

    Macs hmac-sha2-512,hmac-sha2-256,hmac-sha1
    KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group14-sha1

    PasswordAuthentication yes
    PubkeyAuthentication no
    KbdInteractiveAuthentication no
    PermitRootLogin no
    AllowUsers scanner
    AuthorizedKeysFile none

    ForceCommand internal-sftp
    ChrootDirectory /var/lib/scanner
    Subsystem sftp internal-sftp

    AllowTcpForwarding no
    X11Forwarding no
    AllowAgentForwarding no
    PermitTunnel no

    MaxAuthTries 3
    LoginGraceTime 30
    ClientAliveInterval 60
    ClientAliveCountMax 3

    UsePAM yes

    LogLevel VERBOSE
    SyslogFacility AUTH
  '';
in
{
  systemd.services.sshd-scanner-keygen = {
    description = "Generate SSH host key for scanner sshd";
    wantedBy = [ "sshd-scanner.service" ];
    before = [ "sshd-scanner.service" ];
    unitConfig.ConditionPathExists = "!/etc/ssh/ssh_host_rsa_key_scanner";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe' pkgs.openssh "ssh-keygen"} -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key_scanner -N \"\"";
    };
  };

  systemd.services.sshd-scanner = {
    description = "SSH Daemon for Scanner (LAN only)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sshd-scanner-keygen.service"
    ];
    wants = [
      "network-online.target"
      "sshd-scanner-keygen.service"
    ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      ExecStart = "${lib.getExe' pkgs.openssh "sshd"} -D -e -f ${scannerSshdConfig}";
      KillMode = "process";
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 2222 -j ACCEPT
    iptables -A INPUT -p tcp --dport 2222 -j DROP
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp -s 192.168.1.0/24 --dport 2222 -j ACCEPT || true
    iptables -D INPUT -p tcp --dport 2222 -j DROP || true
  '';
}
