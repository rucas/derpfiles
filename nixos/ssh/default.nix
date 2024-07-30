{ ... }: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment = {
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "1w";
      overalljails = true;
    };
    ignoreIP = [ "192.168.1.0/24" ];

    daemonSettings = {
      Definition = {
        logtarget = "SYSLOG";
        socket = "/var/run/fail2ban/fail2ban.sock";
        pidfile = "/var/run/fail2ban/fail2ban.pid";
        dbfile = "/var/lib/fail2ban/fail2ban.sqlite3";
      };
    };
  };

  networking.firewall = { allowedTCPPorts = [ 22 ]; };

  users.users.lucas = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKCLdEAArRtMhdvIdXKbBE19qhS3R2pL4Ws79d0U3czlAAAAEHNzaDpydWNhc2xhYi5jb20= lucas@rucaslab.com"
    ];
  };
}
