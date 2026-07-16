{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) builders;
in
{
  services.home-assistant.config."scene manual" = [
    (builders.mkScene {
      name = "TV";
      entities = {
      };
    })

    (builders.mkScene {
      name = "Arrive";
      entities = {
      };
    })

    (builders.mkScene {
      name = "Leave";
      entities = {
      };
    })
  ];
}
