{ pkgs, config, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
    };
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

  # allow users to login via ssh
  #security.pam.enableSSHAgentAuth = true;

  #security.pam.services.sudo = {
  #  rules.auth.rssh = {
  #    enable = true;
  #    order = config.rules.auth.ssh_agent_auth.order - 1;
  #    control = "sufficient";
  #    modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
  #    settings.authorized_keys_command =
  #      pkgs.writeShellScript "get-authorized-keys" ''
  #        cat "/etc/ssh/authorized_keys.d/$1"
  #      '';
  #  };
  #};
  ## Keep SSH_AUTH_SOCK when sudo'ing
  #security.sudo.extraConfig = ''
  #  Defaults env_keep+=SSH_AUTH_SOCK
  #'';
}
