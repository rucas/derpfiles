# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../nixos/adguard
    ../../nixos/ssh
    ../../nixos/tailscale
    ../../nixos/unlockr
    ../../nixos/caddy
    ../../nixos/postgresql
    ../../nixos/home-assistant
    ../../nixos/dynamicdns
    ../../nixos/zwave-js-ui
    ../../nixos/mosquitto
    ../../nixos/esphome
    ../../nixos/uptime-kuma
    ../../nixos/grafana
    ../../nixos/prometheus
    ../../nixos/loki
    ../../nixos/alloy
    ../../nixos/changedetection-io
    ../../nixos/ntfy-sh
    ../../nixos/papra
    ../../nixos/lldap
    ../../nixos/authelia
    ../../nixos/cloudflared
    ../../nixos/sanoid
    ../../nixos/restic
    ../../nixos/ollama

  ];

  age.secrets = {
    tailscale = {
      file = ./secrets/tailscale.age;
    };

    cloudflare = {
      file = ./secrets/cloudflare.age;
    };
    cloudflare_dynamicdns = {
      file = ./secrets/cloudflare_dynamicdns.age;
    };
    lutron = {
      file = ./secrets/lutron.age;
      path = "/var/lib/hass/lutron.key";
      owner = "hass";
      group = "hass";
    };
    zigbee2mqtt = {
      file = ./secrets/zigbee2mqtt.age;
      path = "/var/lib/zigbee2mqtt/secret.yaml";
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
    };
    mosquitto = {
      file = ./secrets/mosquitto.age;
    };
    zwave-js-ui = {
      file = ./secrets/zwave_js_ui.age;
    };
    nix = {
      file = ./secrets/nix.age;
    };
    lldap_key_seed = {
      file = ./secrets/lldap_key_seed.age;
      owner = "lldap";
      group = "lldap";
    };
    lldap_jwt_secret = {
      file = ./secrets/lldap_jwt_secret.age;
      owner = "lldap";
      group = "lldap";
    };
    lldap_ldap_user_pass = {
      file = ./secrets/lldap_ldap_user_pass.age;
      owner = "lldap";
      group = "lldap";
    };
    authelia_jwt_secret = {
      file = ./secrets/authelia_jwt_secret.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_storage_encryption_key = {
      file = ./secrets/authelia_storage_encryption_key.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_authentication_backend_ldap_password = {
      file = ./secrets/authelia_authentication_backend_ldap_password.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_session_secret = {
      file = ./secrets/authelia_session_secret.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_notifier_smtp_password = {
      file = ./secrets/authelia_notifier_smtp_password.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    grafana = {
      file = ./secrets/grafana.age;
      owner = "grafana";
      group = "grafana";
    };
    restic-aws-env = {
      file = ./secrets/restic-aws-env.age;
    };
    restic-password = {
      file = ./secrets/restic-password.age;
    };
    papra_env = {
      file = ./secrets/papra_env.age;
      owner = "papra";
      group = "papra";
    };
    scanner_password = {
      file = ./secrets/scanner_password.age;
    };
    cloudflared_tunnel_credentials = {
      file = ./secrets/cloudflared_tunnel_credentials.age;
    };
    authelia_oidc_hmac_secret = {
      file = ./secrets/authelia_oidc_hmac_secret.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_oidc_jwks_key = {
      file = ./secrets/authelia_oidc_jwks_key.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
    authelia_oidc_papra_client_secret = {
      file = ./secrets/authelia_oidc_papra_client_secret.age;
      owner = config.services.authelia.instances.rucaslab.user;
      group = config.services.authelia.instances.rucaslab.group;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keyfile for swap LUKS auto-unlock (automatically embedded by systemd-cryptsetup via disko)

  # disko generates /dev/disk/by-partlabel/disk-nvme-* paths, but the disk was
  # partitioned manually so those labels don't exist. Override with stable UUIDs.
  boot.initrd.luks.devices."cryptroot".device =
    lib.mkForce "/dev/disk/by-uuid/9a689bcd-65b3-4228-bb15-19bb42bf117a";
  boot.initrd.luks.devices."cryptswap".device =
    lib.mkForce "/dev/disk/by-uuid/2da48510-45d3-40c0-ac58-1a10c28c424f";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/2DCD-7A19";

  # zfs settings...
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e0f98e67";

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    # Snapshots are managed by Sanoid (nixos/sanoid/default.nix)
    # which provides per-dataset retention policies and drives Syncoid
    # for offsite replication.
    autoSnapshot.enable = false;
  };

  systemd.services.adguardhome.serviceConfig = {
    DynamicUser = pkgs.lib.mkForce false;
    User = "adguardhome";
    Group = "adguardhome";
  };

  users.users.adguardhome = {
    isSystemUser = true;
    group = "adguardhome";
    uid = 62939;
  };

  users.groups.adguardhome.gid = 62939;

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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # needed for NixOs to set shell to zsh.
  # NOTE: https://nixos.wiki/wiki/Command_Shell
  programs.zsh.enable = true;
  users.users.lucas.shell = pkgs.zsh;
  security.sudo.wheelNeedsPassword = false;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # NOTE:
  # https://discourse.nixos.org/t/nixos-rebuild-switch-upgrade-networkmanager-wait-online-service-failure/30746/2
  systemd.services.NetworkManager-wait-online.enable = pkgs.lib.mkForce false;

  # Remove StateDirectory for services using ZFS datasets
  systemd.services.prometheus.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];
  systemd.services.esphome.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];
  systemd.services.esphome.serviceConfig.DynamicUser = pkgs.lib.mkForce false;
  systemd.services.esphome.serviceConfig.User = "esphome";
  systemd.services.esphome.serviceConfig.Group = "esphome";
  systemd.services.uptime-kuma.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];
  systemd.services.uptime-kuma.serviceConfig.DynamicUser = pkgs.lib.mkForce false;
  systemd.services.uptime-kuma.serviceConfig.ProtectSystem = pkgs.lib.mkForce false;
  systemd.services.uptime-kuma.serviceConfig.User = "nobody";
  systemd.services.uptime-kuma.serviceConfig.Group = "nogroup";
  systemd.services.ntfy-sh.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];
  systemd.services.ntfy-sh.serviceConfig.DynamicUser = pkgs.lib.mkForce false;
  systemd.services.ntfy-sh.serviceConfig.ProtectSystem = pkgs.lib.mkForce false;
  systemd.services.ntfy-sh.serviceConfig.User = pkgs.lib.mkForce "ntfy-sh";
  systemd.services.ntfy-sh.serviceConfig.Group = pkgs.lib.mkForce "ntfy-sh";
  systemd.services.lldap.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];
  systemd.services.papra.serviceConfig.StateDirectory = pkgs.lib.mkForce [ ];

  nix = {
    settings = {
      sandbox = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://cache.nixos.org/"
        "https://derpfiles.cachix.org"
        "https://nxvm.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "derpfiles.cachix.org-1:kgIPfQBZenYGvQr3weMaslNjYtfBUMvE3PU+/+Aur8Q="
        "nxvm.cachix.org-1:r4DyiW3QImNfegin8+kxPDOXYt16k+YDzxHhl+tqfRs="
      ];
    };
    gc = {
      automatic = true;
      randomizedDelaySec = "14m";
      options = "--delete-older-than 10d";
    };
    extraOptions = pkgs.lib.optionalString (builtins.pathExists config.age.secrets.nix.path) ''
      # NOTE: need to run sudo nix flake update to use gh token
      include ${config.age.secrets.nix.path}
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

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
