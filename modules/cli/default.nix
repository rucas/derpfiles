{ lib, pkgs, ... }: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./exa.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./gitmux.nix
    ./gitui.nix
    ./tealdeer.nix
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    awscli
    bandwhich

    calc
    coreutils
    curl

    dateutils
    dogdns
    du-dust

    fd

    gitmux
    gnumake
    gnused
    grex

    hexyl
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

    onefetch

    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" ]; })

    # moreutils
    parallel
    poetry
    procs

    ripgrep

    sd
    sqlite

    timer
    tree

    wget

    xsv
    xz
    yq
  ];
}
