{ config, options, lib, pkgs, ... }: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./exa.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./tealdeer.nix
  ];
  home.packages = with pkgs; [
    awscli
    bandwhich
    calc
    curl
    du-dust
    fd
    grex
    gnumake
    htop
    hyperfine
    inetutils
    jq

    (lib.mkIf pkgs.stdenv.isDarwin m-cli)

    neofetch
    nixfmt
    nmap

    # TODO: seperate out to fonts.nix?
    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" ]; })

    # TODO: fix by pinning to nonbroken nix pkgs
    # procs

    ripgrep
    sqlite
    tree
    wget
    xz
    yq
  ];
}
