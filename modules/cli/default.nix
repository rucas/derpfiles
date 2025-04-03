{ lib, pkgs, inputs, ... }: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./direnv.nix
    ./eza.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./gitmux.nix
    ./gitui.nix
    ./tealdeer.nix
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    _1password-cli

    age
    age-plugin-yubikey
    ast-grep
    awscli

    bandwhich

    calc
    coreutils
    curl

    dateutils
    dogdns
    du-dust

    eva

    fd

    gcal
    gitmux
    gnumake
    gnused
    graphviz
    grex

    haskellPackages.patat

    (lib.mkIf pkgs.stdenv.isLinux haveged)
    hexyl
    htop
    hurl
    hyperfine

    inputs.agenix.packages."${system}".default
    inetutils

    jwt-cli
    jq

    (lib.mkIf pkgs.stdenv.isDarwin m-cli)

    # ledger
    lsof

    netcat
    neofetch
    nmap

    onefetch

    nerd-fonts.hack
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    # moreutils
    parallel
    pandoc
    # (lib.mkIf pkgs.stdenv.isDarwin pinentry_mac)
    procs

    ripgrep

    sd
    sqlite

    # tailspin
    timer
    tree
    tokei
    (lib.mkIf pkgs.stdenv.isLinux tor)

    (lib.mkIf pkgs.stdenv.isLinux usbutils)

    wget

    xan
    xz

    yq
    yubikey-manager
  ];
}
