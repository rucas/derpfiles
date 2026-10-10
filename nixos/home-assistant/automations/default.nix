{ ... }:
{
  imports = [
    ./nightly_backup.nix
    ./doorbell_chime.nix
    ./master_bedroom_pico.nix
    ./downstairs_lamps_pico.nix
    ./dishwasher_reminder.nix
    ./robovac_schedule.nix
    ./rusty_crate_privacy.nix
    ./security_camera_privacy.nix
    ./climate_door_pause.nix
    ./hot_water_recirc.nix
    ./wakeup_sunrise.nix
  ];
  services.home-assistant.config = {
    "automation ui" = "!include automations.yaml";
    backup = { };
  };
}
