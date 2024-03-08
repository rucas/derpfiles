# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/adguard
    ../../nixos/ssh
    ../../nixos/tailscale
    ../../nixos/unlockr
    ../../nixos/caddy
    ../../nixos/home-assistant
    ../../nixos/golink
    ../../nixos/dynamicdns
    ../../nixos/zwave-js-ui
  ];

  age.secrets = {
    tailscale = { file = ./secrets/tailscale.age; };
    tailscale_golink = {
      file = ./secrets/tailscale_golink.age;
      owner = config.services.golink.user;
    };
    cloudflare = { file = ./secrets/cloudflare.age; };
    cloudflare_dynamicdns = { file = ./secrets/cloudflare_dynamicdns.age; };
    lutron = {
      file = ./secrets/lutron.age;
      path = "/var/lib/hass/lutron.key";
      owner = "hass";
      group = "hass";
    };
  };

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
    xkb = {
      layout = "us";
      variant = "";
      options = "ctrl:swapcaps";
    };
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

  nix.settings = {
    sandbox = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

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
