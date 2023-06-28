{
  description = "The original derpfiles flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };
    aerial-nvim = {
      url = "github:stevearc/aerial.nvim";
      flake = false;
    };
    alacritty = {
      url = "github:alacritty/alacritty";
      flake = false;
    };
    auto-save-nvim = {
      url = "github:Pocco81/auto-save.nvim/dev";
      flake = false;
    };
    auto-session = {
      url = "github:rmagatti/auto-session";
      flake = false;
    };
    SchemaStore-nvim = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    barbecue-nvim = {
      url = "github:utilyre/barbecue.nvim";
      flake = false;
    };
    better-escape-nvim = {
      url = "github:max397574/better-escape.nvim";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    dashboard-nvim = {
      url = "github:glepnir/dashboard-nvim";
      flake = false;
    };
    diffview-nvim = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    dressing-nvim = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };
    # TODO:
    # pinned until complete rewrite is out.
    fidget-nvim = {
      url = "github:j-hui/fidget.nvim?rev=0ba1e16d07627532b6cae915cc992ecac249fb97";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    glow-nvim = {
      url = "github:ellisonleao/glow.nvim";
      flake = false;
    };
    gruvbox-nvim = {
      url = "github:ellisonleao/gruvbox.nvim";
      flake = false;
    };
    headlines-nvim = {
      url = "github:lukas-reineke/headlines.nvim";
      flake = false;
    };
    indent-blankline-nvim = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    iron-nvim = {
      url = "github:hkupty/iron.nvim";
      flake = false;
    };
    lspkind-nvim = {
      url = "github:onsails/lspkind.nvim";
      flake = false;
    };
    neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
    neogen = {
      url = "github:danymat/neogen";
      flake = false;
    };
    luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    neorg-overlay = { url = "github:nvim-neorg/nixpkgs-neorg-overlay"; };
    # TODO: update once this is fixed
    # https://github.com/nix-community/neovim-nightly-overlay/issues/176
    neovim-nightly = { url = "github:nix-community/neovim-nightly-overlay?rev=c57746e2b9e3b42c0be9d9fd1d765f245c3827b7"; };
    null-ls-nvim = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    nvim-colorizer-lua = {
      url = "github:norcalli/nvim-colorizer.lua";
      flake = false;
    };
    nvim-lualine = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    nvim-navic = {
      url = "github:smiteshp/nvim-navic";
      flake = false;
    };
    nvim-markdown = {
      url = "github:ixru/nvim-markdown";
      flake = false;
    };
    nvim-tree-lua = {
      url = "github:nvim-tree/nvim-tree.lua";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    nvim-ts-rainbow = {
      url = "github:p00f/nvim-ts-rainbow";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    overseer-nvim = {
      url = "github:stevearc/overseer.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    rest-nvim = {
      url = "github:rest-nvim/rest.nvim";
      flake = false;
    };
    session-lens = {
      url = "github:rmagatti/session-lens";
      flake = false;
    };
    telescope-fzf-native-nvim = {
      url = "github:nvim-telescope/telescope-fzf-native.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    telescope-symbols-nvim = {
      url = "github:nvim-telescope/telescope-symbols.nvim";
      flake = false;
    };
    todo-comments-nvim = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    twilight-nvim = {
      url = "github:folke/twilight.nvim";
      flake = false;
    };
    vim-illuminate = {
      url = "github:RRethy/vim-illuminate";
      flake = false;
    };
    vim-nix = {
      url = "github:LnL7/vim-nix";
      flake = false;
    };
    which-key-nvim = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    zen-mode-nvim = {
      url = "github:folke/zen-mode.nvim";
      flake = false;
    };
    spacebar = { url = "github:cmacrae/spacebar"; };
    zsh-vi-mode = {
      url = "github:jeffreytse/zsh-vi-mode";
      flake = false;
    };
    zsh-autopair = {
      url = "github:hlissner/zsh-autopair";
      flake = false;
    };
    fast-syntax-highlighting = {
      url = "github:zdharma-continuum/fast-syntax-highlighting";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, utils, spacebar
    , neovim-nightly, neorg-overlay, ... }:
    let inherit (utils.lib) mkFlake;
    in mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      overlay = import ./overlays { inherit self inputs; };
      sharedOverlays = with self.overlay; [
        alacritty
        neovim-nightly.overlay
        neorg-overlay.overlays.default
        spacebar.overlay
        vimPlugins
        yabai
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
            home-manager.extraSpecialArgs = { inherit inputs; };
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
            home-manager.extraSpecialArgs = {
              inherit inputs;
              theme = builtins.fromTOML
                (builtins.readFile ./modules/themes/gruvbox.toml);
            };
            home-manager.users.awslucas = import ./hosts/c889f3b8f7d7/home.nix;
          }
        ];
      };
    };
}
