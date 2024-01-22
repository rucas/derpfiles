# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/adguard
    ../../nixos/ssh
    ../../nixos/tailscale
  ];

  age.secrets = { tailscale = { file = ./secrets/tailscale.age; }; };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-2da48510-45d3-40c0-ac58-1a10c28c424f".device =
    "/dev/disk/by-uuid/2da48510-45d3-40c0-ac58-1a10c28c424f";
  boot.initrd.luks.devices."luks-2da48510-45d3-40c0-ac58-1a10c28c424f".keyFile =
    "/crypto_keyfile.bin";

  # NOTE: https://nixos.wiki/wiki/Remote_LUKS_Unlocking
  # Remote luks unlock
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    shell = "/bin/cryptsetup-askpass";
    authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKCLdEAArRtMhdvIdXKbBE19qhS3R2pL4Ws79d0U3czlAAAAEHNzaDpydWNhc2xhYi5jb20= lucas@rucaslab.com"
    ];
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

  networking.hostName = "rucaslab";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    xkbOptions = "ctrl:swapcaps";
  };

  console.useXkbConfig = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucas = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # needed for NixOs to set shell to zsh.
  # NOTE: https://nixos.wiki/wiki/Command_Shell
  programs.zsh.enable = true;
  users.users.lucas.shell = pkgs.zsh;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ git vim ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
