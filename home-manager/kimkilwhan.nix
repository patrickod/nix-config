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

  programs.git.extraConfig.core.editor = "vim";

  ## i3 status & keybinding configuration
  ## TODO: migrate to home-manager i3 configuration management
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
}

