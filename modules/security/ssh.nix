{ osConfig, lib, ... }:
let
  isWorkMachine =
    builtins.elem osConfig.networking.hostName [ "lronden-m-vy79p" ];
  isHomeMachine =
    builtins.elem osConfig.networking.hostName [ "rucaslab" "blkmrkt" ];
in {
  programs.ssh = {
    enable = true;
    includes = [ (lib.mkIf isWorkMachine "config.d/*") ];
    matchBlocks = lib.mkMerge [
      # (lib.mkIf isWorkMachine {
      #   "work-*" = {
      #     user = "work-user";
      #     identityFile = "~/.ssh/work_key";
      #   };
      # })
      (lib.mkIf isHomeMachine {
        "phonehome" = {
          user = "lucas";
          hostname = "portal.rucaslab.com";
          port = 2222;
          serverAliveInterval = 30;
          serverAliveCountMax = 3;
          identitiesOnly = true;
          identityFile = "~/.ssh/id_ed25519_sk";
        };
      })
    ];
  };
}
