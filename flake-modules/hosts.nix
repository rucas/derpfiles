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

          inputs.spacebar.overlay
          inputs.nur.overlays.default
        ];
        nix.settings = {
          substituters = [
            "https://cache.nixos.org/"
            "https://derpfiles.cachix.org"
            "https://nxvm.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "derpfiles.cachix.org-1:kgIPfQBZenYGvQr3weMaslNjYtfBUMvE3PU+/+Aur8Q="
            "nxvm.cachix.org-1:r4DyiW3QImNfegin8+kxPDOXYt16k+YDzxHhl+tqfRs="
          ];
        };
        # Determinate Nix owns /etc/nix/nix.conf on darwin and ignores nix.settings.
        # It includes nix.custom.conf for user overrides.
        environment.etc."nix/nix.custom.conf" = lib.mkIf (cfg.env == "darwin") {
          text = ''
            extra-substituters = https://derpfiles.cachix.org https://nxvm.cachix.org
            extra-trusted-public-keys = derpfiles.cachix.org-1:kgIPfQBZenYGvQr3weMaslNjYtfBUMvE3PU+/+Aur8Q= nxvm.cachix.org-1:r4DyiW3QImNfegin8+kxPDOXYt16k+YDzxHhl+tqfRs=
          '';
        };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
            theme = fromTOML (readFile ../modules/themes/gruvbox.toml);
          };
          users.${cfg.username} = import ../hosts/${host}/home.nix;
        };
      };

      # Helper to create system configurations
      mkSystemConfig =
        systemBuilder: host: cfg: extraModules:
        systemBuilder {
          specialArgs = {
            CONF = fromTOML (readFile ../hosts/configs.toml);
            inherit inputs;
          };
          modules = [
            { nixpkgs.hostPlatform.system = cfg.arch; }
            (mkCommonModule host cfg)
          ]
          ++ extraModules;
        };
    in
    {
      flake.darwinConfigurations = lib.mapAttrs (
        host: cfg:
        mkSystemConfig inputs.nix-darwin.lib.darwinSystem host cfg (
          [
            inputs.opnix.darwinModules.default
            ../hosts/${host}/darwin.nix
            inputs.home-manager.darwinModules.home-manager
          ]
          ++ lib.optional (builtins.pathExists ../hosts/${host}/secrets.nix) ../hosts/${host}/secrets.nix
        )
      ) (lib.filterAttrs (n: v: v.env == "darwin") config.hosts);

      flake.nixosConfigurations = lib.mapAttrs (
        host: cfg:
        mkSystemConfig inputs.nixpkgs.lib.nixosSystem host cfg [

          inputs.disko.nixosModules.disko
          ../hosts/${host}/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          inputs.opnix.nixosModules.default
        ]
      ) (lib.filterAttrs (n: v: v.env == "nixos") config.hosts);
    };
}
