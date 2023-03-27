{ ... }: {
  programs.fzf = {
    enable = true;
    fileWidgetCommand = "fd --type f";
    defaultOptions = [
      "--color=fg:#a89984,bg:#282828,hl:#d79921"
      "--color=fg+:#ebdbb2,bg+:#282828,hl+:#fabd2f"
      "--color=info:#83a598,prompt:#b8bb26,pointer:#d65d0e"
      "--color=marker:#8ec07c,spinner:#d3869b,header:#665c54"
    ];
  };
}
