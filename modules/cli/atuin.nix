{ ... }: {
  # NOTE: need to delete before intial build...
  # rm -rf ~/.config/atuin/config.toml && darwin-rebuild switch...
  programs.atuin = {
    enable = true;
    settings = {
      style = "compact";
      enter_accept = false;
      history_filter = [
        "^cr-pull"
        "^darwin-rebuild"
        "^nix build"
        "^tmux"
        "^cat"
        "^which"
        "^cd"
        "^tldr"
        "^vi"
        "^ls"
        "^g "
        "^mwinit"
        "^nvim"
        "^nix flake update"
      ];
    };
  };
}
