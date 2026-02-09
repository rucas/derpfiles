{
  self,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inherit (builtins) fromTOML readFile;
in
{
  options = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            username = lib.mkOption {
              type = lib.types.str;
              description = "Primary user for this host";
            };
            arch = lib.mkOption {
              type = lib.types.str;
              description = "System architecture (e.g., aarch64-darwin, x86_64-linux)";
            };
            env = lib.mkOption {
              type = lib.types.enum [
                "darwin"
                "nixos"
              ];
              default = "darwin";
              description = "Environment type: darwin or nixos";
            };
          };
        }
      );
      default = { };
      description = "Host configurations";
    };
  };

  config =
    let
      # Common configuration shared by all hosts
      mkCommonModule = host: cfg: {
        nixpkgs.config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
        nixpkgs.overlays = [
          self.overlays.default
          inputs.alacritty-theme.overlays.default
          inputs.golink.overlays.default
          inputs.spacebar.overlay
          inputs.nur.overlays.default
        ];
        nix.settings = {
          substituters = [
            "https://cache.nixos.org/"
            "https://derpfiles.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "derpfiles.cachix.org-1:kgIPfQBZenYGvQr3weMaslNjYtfBUMvE3PU+/+Aur8Q="
          ];
        };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          theme = fromTOML (readFile ../modules/themes/gruvbox.toml);
        };
        home-manager.users.${cfg.username} = import ../hosts/${host}/home.nix;
      };

      # Helper to create system configurations
      mkSystemConfig = systemBuilder: host: cfg: extraModules:
        systemBuilder {
          system = cfg.arch;
          specialArgs = {
            CONF = fromTOML (readFile ../hosts/configs.toml);
            inherit inputs;
          };
          modules = [ (mkCommonModule host cfg) ] ++ extraModules;
        };
    in
    {
      flake.darwinConfigurations = lib.mapAttrs (
        host: cfg:
        mkSystemConfig inputs.nix-darwin.lib.darwinSystem host cfg [
          inputs.opnix.darwinModules.default
          ../hosts/${host}/darwin.nix
          ../hosts/${host}/secrets.nix
          inputs.home-manager.darwinModules.home-manager
        ]
      ) (lib.filterAttrs (n: v: v.env == "darwin") config.hosts);

      flake.nixosConfigurations = lib.mapAttrs (
        host: cfg:
        mkSystemConfig inputs.nixpkgs.lib.nixosSystem host cfg [
          inputs.golink.nixosModules.default
          ../hosts/${host}/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          inputs.opnix.nixosModules.default
        ]
      ) (lib.filterAttrs (n: v: v.env == "nixos") config.hosts);
    };
}
