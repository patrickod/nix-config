
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware/x260.nix
      ../secrets.nix
      <home-manager/nixos>
      ../users/patrickod.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "finn"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = false;
  networking.interfaces.wlp4s0.useDHCP = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "20.03"; # Did you read the comment?

}
