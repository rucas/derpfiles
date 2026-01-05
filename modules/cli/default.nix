{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./claude-code.nix
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
    amp-cli
    ast-grep
    awscli2

    bandwhich

    cachix
    calc
    coreutils
    curl

    dateutils
    doggo
    dust

    eva

    fd
    fnm

    gcal
    git-crypt
    gitmux
    gnumake
    gnused
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    ))
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
    inter

    jira-cli-go
    jwt-cli
    jq

    kubectl
    kubectx

    # ledger
    lsof

    (lib.mkIf pkgs.stdenv.isDarwin m-cli)

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
    pre-commit
    procs

    rainfrog
    ripgrep

    sd
    sqlite

    tailspin
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
