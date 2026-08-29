{ ... }:
{
  imports = [
    ./nightly_backup.nix
    ./doorbell_chime.nix
    ./master_bedroom_pico.nix
    ./downstairs_lamps_pico.nix
    ./dishwasher_button.nix
    ./dishwasher_reminder.nix
    ./rusty_crate_privacy.nix
  ];
  services.home-assistant.config = {
    "automation ui" = "!include automations.yaml";
    backup = { };
  };
}
