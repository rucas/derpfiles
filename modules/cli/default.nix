{ lib, pkgs, ... }: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./exa.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./gitui.nix
    ./tealdeer.nix
  ];
  home.packages = with pkgs; [
    awscli
    bandwhich
    calc
    coreutils
    curl
    dogdns
    du-dust
    fd
    grex
    gnumake
    htop
    hurl
    hyperfine
    inetutils
    jwt-cli
    jq

    (lib.mkIf pkgs.stdenv.isDarwin m-cli)

    netcat
    neofetch
    nmap

    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" ]; })

    # moreutils
    parallel
    poetry
    procs

    ripgrep
    sd
    sqlite
    tree
    wget
    xsv
    xz
    yq
  ];
}
