{
  services.prometheus.exporters.node.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # set NOPASSWD sudoers
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
