{ ... }:
{
  imports = [
    ./nightly_backup.nix
    ./doorbell_chime.nix
  ];
  services.home-assistant.config = {
    "automation ui" = "!include automations.yaml";
    backup = { };
  };
}
