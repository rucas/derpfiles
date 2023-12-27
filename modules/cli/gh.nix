{ ... }: {
  programs.gh = {
    enable = true;
    settings = {
      # Workaround for https://github.com/nix-community/home-manager/issues/4744
      version = 1;
    };
  };
}
