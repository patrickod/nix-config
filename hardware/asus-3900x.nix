# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/ezpassthru.nix ];

  # configure necessary virtualization packages
  environment.systemPackages = with pkgs; [ virtmanager qemu ntfs3g ];

  # configure GRUB
  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      useOSProber = true;
    };
  };

  # Configure initial LUKS container decryption pre-LVM
  boot.initrd.luks.devices = {
    prismo-pv = {
      device = "/dev/disk/by-uuid/a3313d00-2023-471b-b7df-70d64dbbf232";
      preLVM = true;
    };
    guests-pv = {
      device = "/dev/disk/by-uuid/5a697699-7317-42eb-a0b8-a2403290e28c";
      preLVM = true;
    };
  };

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "pcie_aspm=off" ];
  boot.kernelModules = [ "kvm-amd" "vfio-pci" ];
  boot.extraModulePackages = [ ];

  # Configure PCI passthrough RTX
  services.ezpassthru = {
    enable = true;
    PCIs = {
      "10de:2204" = "0000:05:00.0"; # RTX3090 Video
      "10de:1aef" = "0000:05:00.1"; # RTX3090 Audio
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6791871d-b2cc-482b-b711-3cace57bab08";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d753b535-4758-4ae6-8281-cd0f455feae5";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EA5C-C3B7";
    fsType = "vfat";
  };

  fileSystems."/mnt/guests" = {
    device = "/dev/prismo-vm-vg/guest-roots";
    fsType = "btrfs";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/e43f8b57-5651-4881-960d-9524d805b97c"; }];

  nix.maxJobs = lib.mkDefault 24;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
