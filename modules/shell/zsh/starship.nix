{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      git_branch = {
        style = "purple";
        symbol = "";
      };
      command_timeout = 1000;
    };
  };
}
