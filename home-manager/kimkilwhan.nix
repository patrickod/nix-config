{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];
  programs.zsh.initExtra = ''
    # pyenv initialization
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    # rbenv initialization
    eval "$(rbenv init -)"
  '';
}

