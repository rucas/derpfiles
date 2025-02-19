{ ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "phonehome" = {
        user = "lucas";
        hostname = "portal.rucaslab.com";
        port = 2222;
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519_sk";
      };
    };
  };
}
