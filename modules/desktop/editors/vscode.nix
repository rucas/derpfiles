{ config, options, lib, pkgs, ... }: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [ bbenoist.nix vscodevim.vim brettm12345.nixfmt-vscode ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "gruvbox-material";
        publisher = "sainnhe";
        version = "6.5.1";
        sha256 = "sha256-+JU/pwIFmrH8wXqC9hh59iJS22zs7ITYhEwWf676RJU=";
      }];
    userSettings = {
      "workbench.colorTheme" = "Gruvbox Material Dark Medium";
      "editor.formatOnSave" = true;
    };
  };
}
