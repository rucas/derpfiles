_: {
  programs.fzf = {
    enable = true;
    fileWidget = {
      command = "fd --type f";
      options = [ "--preview 'bat --color=always --line-range=:500 --style=plain {}'" ];
    };
    changeDirWidget = {
      command = "fd -L --max-depth=2 --type=directory";
      options = [ "--preview 'tree -C {} | head -200'" ];
    };
    # Atuin owns Ctrl-R; disable fzf's history widget to avoid the conflict.
    historyWidget.command = "";
    defaultOptions = [
      "--color=fg:#a89984,bg:#282828,hl:#d79921"
      "--color=fg+:#ebdbb2,bg+:#282828,hl+:#fabd2f"
      "--color=info:#83a598,prompt:#b8bb26,pointer:#d65d0e"
      "--color=marker:#8ec07c,spinner:#d3869b,header:#665c54"
    ];
  };
}
