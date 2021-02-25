{
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # set NOPASSWD sudoers
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
