# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/nix-ismacho.nix) ];

  imports = [
    ../hardware/x1-carbon.nix
    ../modules/defaults.nix
    ../users/patrickod.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kimkilwhan"; # Define your hostname.
  networking.wireless.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.wireless.networks = {
    "Cafe Sophie" = {
      pskRaw =
        "e156bbdd4b632fd2f0e1ca18a01944acbe825d9384ffc1a65b6a91cccd719e82";
    };
  };
  hardware.enableRedistributableFirmware = true;

  # enable bluetooth HW and audio support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  system.stateVersion = "21.05"; # Did you read the comment?

}

