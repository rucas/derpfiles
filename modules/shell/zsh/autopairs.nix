{ config, option, lib, pkgs, ... }: {
  programs.zsh = {
    plugins = [{
      name = "zsh-autopairs";
      file = "autopair.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "hlissner";
        repo = "zsh-autopair";
        rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
        sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
      };
    }];
  };
}
