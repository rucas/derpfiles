{ ... }:
{
  imports = [
    ./gpg-agent.nix
    ./homebrew.nix
    ./jankyborders.nix
    ./launchd.nix
    ../services/ledger-sync.nix
    ./skhd.nix
    ./spacebar.nix
    ./system.nix
    ./yabai.nix
  ];
}
