{
  description = "the derpfiles original flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    fidget-nvim = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };

    todo-comments-nvim = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };

    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    gruvbox-nvim = {
      url = "github:ellisonleao/gruvbox.nvim";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, utils, ... }:
    let theme = import ./modules/theme.nix;

    in (utils.lib.mkFlake) {
      inherit self inputs;

      channelsConfig.allowUnfree = true;
      sharedOverlays = [
        (self: super:
          let
            fidget-nvim = super.vimUtils.buildVimPluginFrom2Nix {
              name = "fidget-nvim";
              src = inputs.fidget-nvim;
            };
            gitsigns-nvim = super.vimUtils.buildVimPluginFrom2Nix {
              name = "gitsigns-nvim";
              src = inputs.gitsigns-nvim;
            };
            todo-comments-nvim = super.vimUtils.buildVimPluginFrom2Nix {
              name = "todo-comments-nvim";
              src = inputs.todo-comments-nvim;
            };
            gruvbox-nvim = super.vimUtils.buildVimPluginFrom2Nix {
              name = "gruvbox-nvim";
              src = inputs.gruvbox-nvim;
            };
          in {
            vimPlugins = super.vimPlugins // {
              inherit todo-comments-nvim gruvbox-nvim;
            };
          })
      ];
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
