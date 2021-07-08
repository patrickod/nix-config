{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ../hardware/x260.nix
    <home-manager/nixos>
    ../modules/defaults.nix
    ../users/patrickod.nix
    ../modules/musnix
    ../modules/strangeparts-wireguard.nix
    ../modules/cafe-sophie-wireless.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "finn"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.interfaces = ["wlp4s0"];

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = false;
  networking.interfaces.wlp4s0.useDHCP = true;

  # realtime audio
  musnix.enable = true;

  # enable bluetooth HW and audio support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "20.03"; # Did you read the comment?
}
