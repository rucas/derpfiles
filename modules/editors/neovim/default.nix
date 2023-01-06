{ config, options, lib, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    extraConfig = "lua require('init')";
    plugins = with pkgs.vimPlugins; [
      {
        plugin =
          (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars));
        type = "lua";
        config = builtins.readFile (./lua/plugins/telescope/init.lua);
      }
      SchemaStore-nvim
      {
        plugin = auto-save-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/autosave/init.lua);
      }
      {
        plugin = auto-session;
        type = "lua";
        config = builtins.readFile (./lua/plugins/auto-session/init.lua);
      }
      {
        plugin = better-escape-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/better-escape/init.lua);
      }
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-path
      #{ plugin = dashboard-nvim; config = builtins.readFile(./plugins/)}
      dashboard-nvim
      {
        plugin = fidget-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/fidget/init.lua);
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/gitsigns/init.lua);
      }
      glow-nvim
      gruvbox-nvim
      headlines-nvim
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/indent-blankline/init.lua);
      }
      {
        plugin = iron-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/iron-nvim/init.lua);
      }
      lspkind-nvim
      luasnip
      neodev-nvim
      {
        plugin = neorg;
        type = "lua";
        #config = builtins.readFile (./lua/plugins/neorg/init.lua);
      }
      null-ls-nvim
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-autopairs/init.lua);
      }
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-cmp/init.lua);
      }
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-colorizer/init.lua);
      }
      {
        plugin = nvim-lualine;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-lualine/init.lua);
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-lspconfig/init.lua);
      }
      nvim-markdown
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-tree/init.lua);
      }
      nvim-ts-rainbow
      nvim-web-devicons
      playground
      plenary-nvim
      {
        plugin = rest-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/rest/init.lua);
      }
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/telescope/init.lua);
      }
      telescope-symbols-nvim
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/todo-comments/init.lua);
      }
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/toggleterm/init.lua);
      }
      {
        plugin = twilight-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/twilight/init.lua);
      }
      {
        plugin = vim-illuminate;
        type = "lua";
        config = builtins.readFile (./lua/plugins/vim-illuminate/init.lua);
      }
      vim-nix
      {
        plugin = which-key-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/which-key/init.lua);
      }
      {
        plugin = zen-mode-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/zen-mode/init.lua);
      }
    ];
    extraPackages = with pkgs; [
      isort
      black
      nil
      nixfmt
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-json-languageserver
      nodePackages.pyright
      shellcheck
      shfmt
      statix
      stylua
      sumneko-lua-language-server
    ];
    viAlias = true;
  };

  xdg.configFile = {
    "nvim/lua" = {
      source = ./lua;
      recursive = true;
    };
  };
}
