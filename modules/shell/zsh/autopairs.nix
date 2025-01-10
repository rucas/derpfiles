{ pkgs, ... }: {
  programs.zsh = {
    plugins = [{
      name = "zsh-autopairs";
      file = "share/zsh/zsh-autopair/autopair.zsh";
      src = pkgs.zsh-autopair;
    }];
  };
}
