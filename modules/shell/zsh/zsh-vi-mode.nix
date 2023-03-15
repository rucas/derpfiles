{ inputs, ... }: {
  programs.zsh = {
    sessionVariables = { ZVM_INIT_MODE = "sourcing"; };
    plugins = [{
      name = "zsh-vi-mode";
      file = "zsh-vi-mode.zsh";
      src = inputs.zsh-vi-mode;
    }];
  };
}
