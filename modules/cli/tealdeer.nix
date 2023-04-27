{ ... }: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      updates = { auto_update = false; };
    };
  };
}
