{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      git_status = { disabled = true; };
      git_branch = {
        style = "purple";
        symbol = "";
        # disabled = true;
      };
      command_timeout = 1000;
    };
  };
}
