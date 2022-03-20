{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ../hardware/x260.nix
    ../modules/defaults.nix
    ../users/patrickod.nix
    ../modules/strangeparts-wireguard.nix
  ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig =
    "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "finn"; # Define your hostname.
  networking.wireless.enable =
    true; # Enables wireless support via wpa_supplicant.
  networking.wireless.interfaces = [ "wlp4s0" ];
  networking.wireless.networks = {
    "Cafe Sophie" = {
      pskRaw =
        "e156bbdd4b632fd2f0e1ca18a01944acbe825d9384ffc1a65b6a91cccd719e82";
    };
  };
  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = false;
  networking.interfaces.wlp4s0.useDHCP = true;

  # enable bluetooth HW and audio support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  system.stateVersion = "20.03"; # Did you read the comment?
}
