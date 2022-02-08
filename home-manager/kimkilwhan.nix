{ config, pkgs, ... }:

{
  imports = [ ./common.nix ../modules/home-manager/restic ];
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

  services.restic-home-backup.enable = true;

  ## i3 status & keybinding configuration
  ## TODO: migrate to home-manager i3 configuration management
  xdg.configFile."i3/status.toml".source =
    ../dotfiles/i3status-rs.kimkilwhan.toml;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config.kimkilwhan;

}

