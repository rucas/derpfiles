{ pkgs, inputs, vimUtils, ... }:
let
  vimFlakes = [
    "SchemaStore-nvim"
    "autosave-nvim"
    "better-escape-nvim"
    "cmp-buffer"
    "cmp-cmdline"
    "cmp-nvim-lsp"
    "cmp-path"
    "dashboard-nvim"
    "fidget-nvim"
    "gitsigns-nvim"
    "glow-nvim"
    "gruvbox-nvim"
    "headlines-nvim"
    "indent-blankline-nvim"
    "iron-nvim"
    "lspkind-nvim"
    "luasnip"
    "neodev-nvim"
    "neorg"
    "null-ls-nvim"
    "nvim-autopairs"
    "nvim-colorizer-lua"
    "nvim-markdown"
    "nvim-lspconfig"
    "nvim-lualine"
    "nvim-tree-lua"
    #"nvim-treesitter"
    "nvim-ts-rainbow"
    "nvim-web-devicons"
    "nvim-cmp"
    "plenary-nvim"
    "rest-nvim"
    "telescope-file-browser-nvim"
    "telescope-nvim"
    "telescope-symbols-nvim"
    # "telescope-fzf-native-nvim"
    "todo-comments-nvim"
    "twilight-nvim"
    "vim-illuminate"
    "vim-nix"
    "which-key-nvim"
    "zen-mode-nvim"
  ];
  buildPlug = name:
    vimUtils.buildVimPluginFrom2Nix {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
    };
in builtins.listToAttrs (map (name: {
  name = name;
  value = buildPlug name;
}) vimFlakes)
