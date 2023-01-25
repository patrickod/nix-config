{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = [
    pkgs._1password-gui
    pkgs.zoom-us
    pkgs.beets
    pkgs.kid3
    pkgs.picard
    pkgs.slack
    pkgs.discord
    pkgs.obs-studio
    pkgs.zeal
  ];

  # prismo specific i3 configuration
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml.prismo;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config;

  home.file.".ssh/allowed_signers".text =
    "* ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnVbaP3o6F5ri9NMS+oAoZ6GlEq7h5XRAe9pgGJBnsg patrickod@prismo";

}

