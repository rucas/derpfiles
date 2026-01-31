{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities builders;
in
{
  services.home-assistant.config.notify = [
    (builders.mkNotifyGroup {
      name = "all_mobile";
      unique_id = "all_mobile";
      services = entities.allMobileDevices;
    })
  ];
}
