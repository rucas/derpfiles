{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkForce;
  cfg = config.services.esphome;
in
{
  services = {
    esphome = {
      enable = true;
    };
  };

  # esphome 2026.8 compiles ESP32 targets through its own ESP-IDF installer
  # rather than nixpkgs' FHS-wrapped platformio, so Espressif's generic-linux
  # prebuilts (cmake, ninja, xtensa-esp-elf) need nix-ld to find a loader.
  # libusb1 is for openocd, whose install check esphome runs for ESP32 targets.
  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.libusb1 ];
  };

  # esphome 2026.8 removed the built-in `esphome dashboard` command; the
  # dashboard now ships separately as esphome-device-builder.
  systemd.services.esphome = {
    path = [ pkgs.esphome-device-builder ];
    serviceConfig.ExecStart = mkForce "${getExe pkgs.esphome-device-builder} --host ${cfg.address} --port ${toString cfg.port} /var/lib/esphome";
  };
}
