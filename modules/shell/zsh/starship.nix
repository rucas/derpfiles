_: {
  programs.starship = {
    enable = true;
    settings = {
      git_status = {
        disabled = true;
      };
      python = {
        disabled = true;
      };
      git_branch = {
        style = "purple";
        symbol = "";
      };
      command_timeout = 1000;
    };
  };
}
