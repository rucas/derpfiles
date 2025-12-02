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
  ];

  programs.home-manager.enable = true;

  programs.claude-code = {
    enable = true;
    memory.text = ''
      - **Language:** English only - all code, comments, docs, examples, commits, configs, errors, tests
      - **Tools**: Use rg not grep, fd not find, tree is installed
      - **Style**: Prefer self-documenting code over comments
    '';
    mcpServers = {
      fetch = {
        command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
      };
      git = {
        command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
        args = [ "--repository" "." ];
      };
      time = {
        command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
      };
    };
  };

  home.username = "lucas";

  home.stateVersion = "22.11";

  fonts.fontconfig.enable = true;

  home.packages = [
    (import ../../pkgs/dnd pkgs)
    (import ../../pkgs/shortuuid pkgs)
    inputs.nxvm.packages.${pkgs.system}.default
  ];

  # NOTE: used for nvim
  xdg.dataFile."dict/words".source = inputs.english-words + "/words_alpha.txt";
}
