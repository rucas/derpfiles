{
  pkgs,
  inputs,
  ...
}:
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
    model = "claude-opus-4-6";
    mcpServers = {
      fetch.enable = true;
      git.enable = true;
      time.enable = true;
      github.enable = true;
      rollbar.enable = true;
      jira.enable = true;
      chronosphere.enable = true;
      playwright.enable = true;
      snowflake.enable = true;
    };
  };

  home = {
    username = "lucas.rondenet";
    stateVersion = "22.11";
    packages = [
      (import ../../pkgs/dnd pkgs)
      (import ../../pkgs/git-wt pkgs)
      (import ../../pkgs/shortuuid pkgs)
      inputs.nxvm.packages.${pkgs.system}.default
      inputs.opnix.packages.${pkgs.system}.default
    ];
  };

  fonts.fontconfig.enable = true;

  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";

  services.ledger-sync.enable = true;
}
