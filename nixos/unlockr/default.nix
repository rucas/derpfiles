{ pkgs, configs, ... }: {
  # NOTE: https://nixos.wiki/wiki/Remote_LUKS_Unlocking
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    shell = "/bin/cryptsetup-askpass";
    authorizedKeys = configs.hosts.rucaslab.trusted;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
  boot.kernelParams = [ "ip=dhcp" ];
  # copy your onion folder
  boot.initrd.secrets = { "/etc/tor/onion/bootup" = /home/lucas/tor/onion; };

  # copy tor to you initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.haveged}/bin/haveged
    copy_bin_and_libs ${pkgs.tor}/bin/tor
  '';

  # start tor during boot process
  boot.initrd.network.postCommands = let
    torRc = (pkgs.writeText "tor.rc" ''
      DataDirectory /etc/tor
      SOCKSPort 127.0.0.1:9050 IsolateDestAddr
      SOCKSPort 127.0.0.1:9063
      HiddenServiceDir /etc/tor/onion/bootup
      HiddenServicePort 22 127.0.0.1:22
    '');
  in ''
    echo "tor: preparing onion folder"
    # have to do this otherwise tor does not want to start
    chmod -R 700 /etc/tor

    echo "make sure localhost is up"
    ip a a 127.0.0.1/8 dev lo
    ip link set lo up

    echo "haveged: starting haveged"
    haveged -F &

    echo "tor: starting tor"
    tor -f ${torRc} --verify-config
    tor -f ${torRc} &
  '';
}
