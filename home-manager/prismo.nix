{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.git.extraConfig.core.editor = "emacsclient -c";

  home.packages = [pkgs._1password-gui pkgs.zoom-us];

  # prismo specific i3 configuration
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml.prismo;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config;

}

