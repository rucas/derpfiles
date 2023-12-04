{
  description = "The original derpfiles flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };
    alacritty = {
      url = "github:alacritty/alacritty";
      flake = false;
    };
    alacritty-theme = { url = "github:alexghr/alacritty-theme.nix"; };
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
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    fidget-nvim = {
      url = "github:j-hui/fidget.nvim";
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
    headlines-nvim = {
      url = "github:lukas-reineke/headlines.nvim";
      flake = false;
    };
    indent-blankline-nvim = {
      url = "github:lukas-reineke/indent-blankline.nvim";
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
    neovim-nightly = { url = "github:nix-community/neovim-nightly-overlay"; };
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
    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    nvim-window-picker = {
      url = "github:s1n7ax/nvim-window-picker";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    rainbow-delimiters = {
      url = "git+https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git";
      flake = false;
    };
    rest-nvim = {
      url = "github:rest-nvim/rest.nvim";
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
    , neovim-nightly, neorg-overlay, alacritty-theme, ... }:
    let inherit (utils.lib) mkFlake;
    in mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      overlay = import ./overlays { inherit self inputs; };
      sharedOverlays = with self.overlay; [
        alacritty-theme.overlays.default
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

      hosts.rucaslab = {
        builder = nixpkgs.lib.nixosSystem;
        system = "x86_64-linux";
        modules = [
          ./hosts/rucaslab/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              theme = builtins.fromTOML
                (builtins.readFile ./modules/themes/gruvbox.toml);
            };
            home-manager.users.lucas = import ./hosts/rucaslab/home.nix;
          }
        ];
      };
    };
}
