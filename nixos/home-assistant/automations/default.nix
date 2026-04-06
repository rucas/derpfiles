{ ... }:
{
  imports = [
    ./nightly_backup.nix
    ./doorbell_chime.nix
    ./master_bedroom_pico.nix
    ./downstairs_lamps_pico.nix
  ];
  services.home-assistant.config = {
    "automation ui" = "!include automations.yaml";
    backup = { };
  };
}
