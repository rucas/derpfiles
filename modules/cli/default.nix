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
    ./claude
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
  home.packages = [
    pkgs._1password-cli

    pkgs.age
    pkgs.age-plugin-yubikey
    pkgs.amp-cli
    pkgs.ast-grep
    pkgs.awscli2

    pkgs.bandwhich

    pkgs.cachix
    pkgs.calc
    pkgs.coreutils
    pkgs.curl

    # dateutils
    pkgs.doggo
    pkgs.dust

    pkgs.eva

    pkgs.fastfetch
    pkgs.fd
    pkgs.fnm

    pkgs.gcal
    pkgs.git-crypt
    pkgs.gitmux
    pkgs.glow
    pkgs.gnumake
    pkgs.gnused
    (lib.mkIf pkgs.stdenv.isDarwin (
      pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
      )
    ))
    pkgs.graphviz
    pkgs.grex

    pkgs.haskellPackages.patat

    (lib.mkIf pkgs.stdenv.isLinux pkgs.haveged)
    pkgs.hexyl
    pkgs.htop
    pkgs.hurl
    pkgs.hyperfine

    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
    pkgs.inetutils
    pkgs.inter

    pkgs.jira-cli-go
    pkgs.jwt-cli
    pkgs.jq

    pkgs.kubectl
    pkgs.kubectx

    pkgs.lsof

    (lib.mkIf pkgs.stdenv.isDarwin pkgs.m-cli)

    pkgs.netcat
    pkgs.nmap

    pkgs.onefetch

    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono

    pkgs.parallel
    pkgs.pandoc
    pkgs.pre-commit
    pkgs.procs

    pkgs.rainfrog
    pkgs.ripgrep

    pkgs.sd
    pkgs.sqlite

    pkgs.tailspin
    pkgs.timer
    pkgs.tree
    pkgs.tokei
    (lib.mkIf pkgs.stdenv.isLinux pkgs.tor)

    (lib.mkIf pkgs.stdenv.isLinux pkgs.usbutils)

    pkgs.wget

    pkgs.xan
    pkgs.xz

    pkgs.yq
    pkgs.yubikey-agent
    pkgs.yubikey-manager
  ];
}
