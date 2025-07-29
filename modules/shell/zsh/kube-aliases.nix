{ inputs, ... }:
{
  programs.zsh = {
    plugins = [
      {
        name = "kube-aliases";
        file = "kube-aliases.plugin.zsh";
        src = inputs.kube-aliases;
      }
    ];
    sessionVariables = {
      ZSH_CUSTOM = "$HOME/.zsh";
    };
  };
}
