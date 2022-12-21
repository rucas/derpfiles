{ inputs, ... }: {
  alacritty = (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (drv: rec {
      src = inputs.alacritty;
      cargoDeps = drv.cargoDeps.overrideAttrs (prev.lib.const {
        inherit src;
        outputHash = "sha256-3reMU7O3E7LXwvFlebm+oZ8QgK+gKPNhc35aW3ICZV0=";
      });
    });
  });
  yabai = (final: prev: { });
  neovim = (final: prev:
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
        "lspkind-nvim"
        "luasnip"
        "neodev-nvim"
        "neorg"
        "null-ls-nvim"
        "nvim-autopairs"
        "nvim-colorizer-lua"
        "nvim-markdown"
        "nvim-lspconfig"
        "nvim-tree-lua"
        "nvim-ts-rainbow"
        "nvim-web-devicons"
        "nvim-cmp"
        "plenary-nvim"
        "rest-nvim"
        "telescope-file-browser-nvim"
        "telescope-nvim"
        "telescope-symbols-nvim"
        "todo-comments-nvim"
        "twilight-nvim"
        "vim-illuminate"
        "vim-nix"
        "which-key-nvim"
        "zen-mode-nvim"
      ];
      buildPlug = name:
        prev.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "master";
          src = builtins.getAttr name inputs;
        };
      neovimPlugins = builtins.listToAttrs (map (name: {
        name = name;
        value = buildPlug name;
      }) vimFlakes);
    in { vimPlugins = prev.vimPlugins // neovimPlugins; });
}
