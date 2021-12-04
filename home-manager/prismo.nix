{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.git.extraConfig.core.editor = "emacsclient -c";

  # prismo specific i3 configuration
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml.prismo;

}

