{ ... }: {
  imports = [ ./nightly_backup.nix ];
  services.home-assistant.config = {
    "automation ui" = "!include automations.yaml";
    backup = { };
  };
}
