{ osConfig, lib, ... }:
let
  isWorkMachine = builtins.elem osConfig.networking.hostName [ "lronden-m-vy79p" ];
  isHomeMachine = builtins.elem osConfig.networking.hostName [
    "rucaslab"
    "blkmrkt"
  ];
in
{
  programs.ssh = {
    enable = true;
    # NOTE:
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/ssh.nix#L555
    enableDefaultConfig = false;
    includes = [ (lib.mkIf isWorkMachine "config.d/*") ];
    settings = lib.mkMerge [
      # (lib.mkIf isWorkMachine {
      #   "work-*" = {
      #     User = "work-user";
      #     IdentityFile = "~/.ssh/work_key";
      #   };
      # })
      (lib.mkIf isHomeMachine {
        "phonehome" = {
          User = "lucas";
          HostName = "portal.rucaslab.com";
          Port = 2222;
          ServerAliveInterval = 30;
          ServerAliveCountMax = 3;
          IdentitiesOnly = true;
          IdentityFile = "~/.ssh/id_ed25519_sk";
          ForwardAgent = true;
        };
        "unlock" = {
          Port = 22;
          User = "root";
          IdentityFile = "~/.ssh/id_ed25519_sk";
          ProxyCommand = "ncat --proxy 127.0.0.1:9050 --proxy-type socks5 $(cat /usr/local/var/opnix/secrets/ssh/onion-host) %p";
          RequestTTY = "yes";
        };
      })
    ];
  };
}
