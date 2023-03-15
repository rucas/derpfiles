{ inputs, ... }: {
  programs.zsh = {
    plugins = [{
      name = "zsh-autopairs";
      file = "autopair.zsh";
      src = inputs.zsh-autopair;
    }];
  };
}
