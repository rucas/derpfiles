{ config, options, lib, pkgs, ... }: {
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
    du-dust
    fd
    grex
    gnumake
    htop
    hyperfine
    inetutils
    jwt-cli
    jq

    (lib.mkIf pkgs.stdenv.isDarwin m-cli)

    neofetch
    nixfmt
    nmap

    # TODO: seperate out to fonts.nix?
    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" ]; })

    moreutils
    procs

    ripgrep
    sd
    sqlite
    tree
    wget
    xz
    yq
  ];
}
