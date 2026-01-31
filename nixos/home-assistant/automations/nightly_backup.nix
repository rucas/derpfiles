{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) mkTimeAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkTimeAutomation {
      id = "nightly_backup_3am";
      alias = "Nightly Backup at 3am";
      time = "03:00:00";
      action = [
        {
          alias = "Create backup now";
          service = "backup.create";
        }
      ];
    })
  ];
}
