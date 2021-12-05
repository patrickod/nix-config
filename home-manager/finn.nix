{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  ## TODO: migrate to home-manager i3 configuration management
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
}

