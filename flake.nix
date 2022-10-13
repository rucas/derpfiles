{
  description = "the derpfiles original flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, utils }:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      hosts.blkmrkt = {
        builder = nix-darwin.lib.darwinSystem;
        system = "x86_64-darwin";
        output = "darwinConfigurations";

        modules = [
          ./hosts/blkmrkt/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lucas = import ./hosts/blkmrkt/home.nix;
          }
        ];
      };

      hosts.c889f3b8f7d7 = {
        builder = nix-darwin.lib.darwinSystem;
        system = "aarch64-darwin";
        output = "darwinConfigurations";

        modules = [
          ./hosts/c889f3b8f7d7/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.awslucas = import ./hosts/c889f3b8f7d7/home.nix;
          }
        ];
      };
    };
}
