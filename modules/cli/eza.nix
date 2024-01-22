{ ... }: {
  programs.eza = { enable = true; };
  programs.zsh.shellAliases = {
    l = "eza -1";
    ls = "eza --group-directories-first";
    la = "eza --group-directories-first -a";
    ll = "eza --group-directories-first --long --header";
    lt = "eza --tree";
  };
}
