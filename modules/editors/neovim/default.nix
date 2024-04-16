{ pkgs, inputs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = ''
      require("init");
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = (nvim-treesitter.withAllGrammars).overrideAttrs (_: {
          version = "2023-02-15";
          src = inputs.nvim-treesitter;
        });
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-treesitter/init.lua);
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
      {
        plugin = conform-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/conform-nvim/init.lua);
      }
      {
        plugin = fidget-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/fidget/init.lua);
      }
      {
        plugin = flatten-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/flatten-nvim/init.lua);
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/gitsigns/init.lua);
      }
      headlines-nvim
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/indent-blankline/init.lua);
      }
      gruvbox-nvim
      lspkind-nvim
      luasnip
      neodev-nvim
      {
        plugin = neogen;
        type = "lua";
        config = builtins.readFile (./lua/plugins/neogen/init.lua);
      }
      {
        plugin = neorg;
        type = "lua";
        config = builtins.readFile (./lua/plugins/neorg/init.lua);
      }
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
        plugin = nvim-window-picker;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-window-picker/init.lua);
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile (./lua/plugins/nvim-tree/init.lua);
      }
      nvim-web-devicons
      playground
      plenary-nvim
      {
        plugin = rainbow-delimiters;
        type = "lua";
        config = builtins.readFile (./lua/plugins/rainbow-delimiters/init.lua);
      }
      {
        plugin = rest-nvim;
        type = "lua";
        config = builtins.readFile (./lua/plugins/rest/init.lua);
      }
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
      black
      isort
      lua-language-server
      marksman
      nil
      nixfmt
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.prettier
      nodePackages.pyright
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      prettierd
      python310Packages.flake8
      shellcheck
      shfmt
      statix
      stylua
      taplo
    ];
    extraLuaPackages = ps: [ ps.nvim-nio ps.xml2lua ps.lua-curl ps.mimetypes ];
    viAlias = true;
  };

  xdg.configFile = {
    "nvim/lua" = {
      source = ./lua;
      recursive = true;
    };
    "nvim/after" = {
      source = ./after;
      recursive = true;
    };
  };
}
