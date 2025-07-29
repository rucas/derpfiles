{ pkgs, ... }:
{
  programs.zsh = {
    plugins = [
      {
        name = "zsh-lazyload";
        src = pkgs.fetchFromGitHub {
          owner = "qoomon";
          repo = "zsh-lazyload";
          rev = "v1.0.1";
          sha256 = "sha256-prV6jUp33HgGayf5PuqyM/17/2hJldxMZZskthtdUxY=";
        };
      }
    ];
    # TODO add check to add only if in brew config
    initContent = ''
      lazyload sdk -- 'export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec && source ''${SDKMAN_DIR}/bin/sdkman-init.sh'
      lazyload pyenv -- 'eval "$(pyenv init -)"; eval "$(pyenv virtualenv-init -)"'
    '';
  };
}
