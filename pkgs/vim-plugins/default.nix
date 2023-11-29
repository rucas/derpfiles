{ inputs, vimUtils, ... }:
let
  vimFlakes = [
    "SchemaStore-nvim"
    "aerial-nvim"
    "autosave-nvim"
    "auto-session"
    "better-escape-nvim"
    "cmp-buffer"
    "cmp-cmdline"
    "cmp-nvim-lsp"
    "cmp-path"
    "dressing-nvim"
    "fidget-nvim"
    "gitsigns-nvim"
    "gruvbox-nvim"
    "headlines-nvim"
    "indent-blankline-nvim"
    "lspkind-nvim"
    "luasnip"
    "neodev-nvim"
    "neogen"
    "null-ls-nvim"
    "nvim-autopairs"
    "nvim-colorizer-lua"
    "nvim-lualine"
    "nvim-markdown"
    "nvim-lspconfig"
    "nvim-lualine"
    "nvim-tree-lua"
    "nvim-web-devicons"
    "nvim-cmp"
    "overseer-nvim"
    "plenary-nvim"
    "rainbow-delimiters"
    "rest-nvim"
    "telescope-nvim"
    "telescope-symbols-nvim"
    "todo-comments-nvim"
    "toggleterm-nvim"
    "twilight-nvim"
    "vim-illuminate"
    "vim-nix"
    "which-key-nvim"
    "zen-mode-nvim"
  ];
  buildPlug = name:
    vimUtils.buildVimPlugin {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
    };
in builtins.listToAttrs (map (name: {
  name = name;
  value = buildPlug name;
}) vimFlakes)
