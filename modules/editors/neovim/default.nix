{ config, options, lib, pkgs, ... }: {
  programs.neovim = {
    enable = true;

    # TODO: missing
    # * Pocco81/AutoSave.nvim
    # * lukas-reineke/headlines.nvim
    # * ixru/nvim-markdown
    plugins = with pkgs.vimPlugins; [
      SchemaStore-nvim
      Shade-nvim
      better-escape-nvim
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-path
      dashboard-nvim
      fidget-nvim
      gitsigns-nvim
      glow-nvim
      gruvbox-flat-nvim
      indent-blankline-nvim
      lspkind-nvim
      lua-dev-nvim
      luasnip
      null-ls-nvim
      nvim-autopairs
      nvim-colorizer-lua
      nvim-lspconfig
      nvim-tree-lua
      nvim-treesitter
      nvim-ts-rainbow
      nvim-web-devicons
      nvim-cmp
      packer-nvim
      plenary-nvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-symbols-nvim
      todo-comments-nvim
      vim-illuminate
      vim-nix
      which-key-nvim
      neorg
      twilight-nvim
      zen-mode-nvim
      rest-nvim
    ];
    extraPackages = with pkgs; [
      shellcheck
      shfmt
      rnix-lsp
      sumneko-lua-language-server
    ];
    viAlias = true;
  };
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/derpfiles/modules/editors/neovim/lua/";
    recursive = true;
  };
  xdg.configFile."nvim/init.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/derpfiles/modules/editors/neovim/init.lua";
  };
}
