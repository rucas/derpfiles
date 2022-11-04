{ config, options, lib, pkgs, ... }: {
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      SchemaStore-nvim
      Shade-nvim
      auto-save-nvim
      better-escape-nvim
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-path
      dashboard-nvim
      fidget-nvim
      gitsigns-nvim
      glow-nvim
      gruvbox-nvim
      headlines-nvim
      indent-blankline-nvim
      lspkind-nvim
      lua-dev-nvim
      luasnip
      neorg
      null-ls-nvim
      nvim-autopairs
      nvim-cmp
      nvim-colorizer-lua
      nvim-lspconfig
      nvim-markdown
      nvim-tree-lua
      nvim-ts-rainbow
      nvim-web-devicons
      playground
      plenary-nvim
      rest-nvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-symbols-nvim
      todo-comments-nvim
      twilight-nvim
      vim-illuminate
      vim-nix
      which-key-nvim
      zen-mode-nvim
    ];
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-json-languageserver
      nodePackages.pyright
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
