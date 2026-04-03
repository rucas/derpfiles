{
  nixpkgs,
  overlays,
  inputs,
}:

hostname:
{
  arch,
  user,
  darwin ? false,
}:
let
  isLinux = !darwin;

  # The config files for that make up a system.
  machineConfig = ../hosts/${hostname}/hardware-configuration.nix;
  userOSConfig = ../hosts/${hostname}/${if darwin then "darwin" else "configuration"}.nix;
  userHMConfig = ../hosts/${hostname}/home.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin then
      # inputs.home-manager.darwinModules
      inputs.home-manager.darwinModules.home-manager
    else
      inputs.home-manager.nixosModules;
  # in systemFunc rec {
in
systemFunc {
  # inherit arch;
  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    {
      nixpkgs.overlays = overlays;
    }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    (if isLinux then machineConfig else { })
    userOSConfig
    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig { inputs = inputs; };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = arch;
        currentSystemName = hostname;
        currentSystemUser = user;
        inputs = inputs;
      };
    }
  ];
}
