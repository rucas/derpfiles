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

  # esphome 2026.8 removed the built-in `esphome dashboard` command; the
  # dashboard now ships separately as esphome-device-builder.
  systemd.services.esphome = {
    path = [ pkgs.esphome-device-builder ];
    serviceConfig.ExecStart = mkForce "${getExe pkgs.esphome-device-builder} --host ${cfg.address} --port ${toString cfg.port} /var/lib/esphome";
  };
}
