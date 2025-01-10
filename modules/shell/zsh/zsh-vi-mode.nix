{ pkgs, ... }: {
  programs.zsh = {
    sessionVariables = {
      ZVM_VI_ESCAPE_BINDKEY = "jk";
      ZVM_INIT_MODE = "sourcing";
    };
    plugins = [{
      name = "vi-mode";
      src = pkgs.zsh-vi-mode;
      file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }];
  };
}
