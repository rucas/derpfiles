{ ... }: {
  services.home-assistant.config = {
    "automation manual" = [{
      id = "nightly_backup_3am";
      alias = "Nightly Backup at 3am";
      trigger = {
        platform = "time";
        at = "03:00:00";
      };
      action = {
        alias = "Create backup now";
        service = "backup.create";
      };
    }];
  };
}
