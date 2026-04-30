{ pkgs, inputs, ... }:
{

  imports = [
    ../../modules/cli
    ../../modules/desktop/browsers
    ../../modules/desktop/editors
    ../../modules/desktop/productivity
    ../../modules/desktop/term
    ../../modules/shell/zsh
    ../../modules/security
    ../../modules/services/ledger-sync.nix
  ];

  programs.home-manager.enable = true;

  programs.claude-code-custom = {
    enable = true;
    # fetch, git, and time are enabled by default
    # memory uses the same default configuration
    mcpServers = {
      homeAssistant = {
        enable = true;
        url = "https://home.rucaslab.com";
      };
      nixos.enable = true;
    };
  };

  home = {
    username = "lucas";
    stateVersion = "22.11";
    packages = [
      (import ../../pkgs/dnd pkgs)
      (import ../../pkgs/git-wt pkgs)
      (import ../../pkgs/shortuuid pkgs)
      inputs.nxvm.packages.${pkgs.system}.default
    ];
  };

  fonts.fontconfig.enable = true;

  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";

  services.ledger-sync.enable = true;
}
