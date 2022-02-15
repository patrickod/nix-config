{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = [pkgs._1password-gui pkgs.zoom-us pkgs.obs-studio];

  # prismo specific i3 configuration
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml.prismo;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config;

}

