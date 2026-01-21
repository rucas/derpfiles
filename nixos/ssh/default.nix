{
  pkgs,
  config,
  lib,
  ...
}:
{
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

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };

  users.users.lucas = {
    openssh.authorizedKeys.keys = [
      # FIDO2 key for SSH authentication
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKCLdEAArRtMhdvIdXKbBE19qhS3R2pL4Ws79d0U3czlAAAAEHNzaDpydWNhc2xhYi5jb20= lucas@rucaslab.com"

      # Regular ed25519 key for sudo authentication via agent forwarding
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO06wFEJR3Y9YFfo45RqirpDzJ+Qy8dj0GWvZhbbEIwu sudo-auth-key"
    ];
  };

  # Configure SSH agent auth for sudo
  security.pam.enableSSHAgentAuth = true;

  # Override the ssh_agent_auth file location
  security.pam.services.sudo.rules.auth.ssh_agent_auth.settings.file =
    lib.mkForce "/etc/ssh/authorized_keys.d/lucas";

  # Keep SSH_AUTH_SOCK when sudo'ing
  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
}
