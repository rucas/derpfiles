{ lib }:
let
  entities = import ./entities.nix { inherit lib; };
  helpers = import ./helpers.nix { inherit lib entities; };
  builders = import ./builders.nix { inherit lib entities helpers; };
in
{
  inherit entities helpers builders;

  inherit (helpers)
    triggers
    conditions
    actions
    sequence
    ;
  inherit (builders)
    mkAutomation
    mkTimeAutomation
    mkStateAutomation
    mkZoneAutomation
    mkBlueprintAutomation
    mkMultiTriggerAutomation
    ;
}
