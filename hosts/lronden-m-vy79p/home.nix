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
    ../../modules/services/git-wt.nix
  ];

  programs = {
    home-manager.enable = true;

    claude-code-custom = {
      enable = true;
      model = "claude-opus-4-8";
      gradleEnv.enable = true;
      agentTeams.enable = true;
      commands = {
        note.enable = true;
        commit.enable = true;
        plan-to-jira.enable = true;
        resolve-conflicts.enable = true;
        fix-ci.enable = true;
        address-review.enable = true;
      };
      mcpServers = {
        buildkite.enable = true;
        fetch.enable = true;
        git.enable = true;
        time.enable = true;
        github.enable = true;
        rollbar.enable = true;
        jira.enable = true;
        chronosphere.enable = true;
        playwright.enable = true;
        snowflake.enable = true;
        notion.enable = true;
      };
    };

    git-wt = {
      enable = true;
      repos = [ { path = "/Users/lucas.rondenet/Code/derpfiles"; } ];
      configFile = "/usr/local/var/opnix/secrets/git-wt/config";
    };
  };

  home = {
    username = "lucas.rondenet";
    stateVersion = "22.11";
    packages = [
      (import ../../pkgs/dnd pkgs)
      (import ../../pkgs/shortuuid pkgs)
      inputs.nxvm.packages.${pkgs.system}.default
      inputs.opnix.packages.${pkgs.system}.default
    ];
  };

  fonts.fontconfig.enable = true;

  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";

  services.ledger-sync.enable = true;
}
