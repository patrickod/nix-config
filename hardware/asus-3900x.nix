# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ../modules/ezpassthru.nix
    ];

    # configure necessary virtualization packages
    environment.systemPackages = with pkgs; [
      virtmanager
      qemu
    ];

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
    };

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = ["amd_iommu=on" "iommu=pt" "pcie_aspm=off" "hugepages=8192"];
    boot.kernelModules = [ "kvm-amd" "vfio-pci" ];
    boot.extraModulePackages = [ ];

    # Configure PCI passthrough for:
    #  * RTX 2070 Super x 4 (VGA, Audio, USB, Serial)
    #  * USB expansion card
    services.ezpassthru = {
      enable = true;
      PCIs = {
        "10de:1e84" = "0000:05:00.0";
        "10de:10f8" = "0000:05:00.1";
        "10de:1ad8" = "0000:05:00.2";
        "10de:1ad9" = "0000:05:00.3";
      };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/6791871d-b2cc-482b-b711-3cace57bab08";
      fsType = "btrfs";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/380f9079-9016-4f55-bfa2-3aa4e8a46107";
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

    swapDevices = [
      {
        device = "/dev/disk/by-uuid/e43f8b57-5651-4881-960d-9524d805b97c";
      }
    ];

    nix.maxJobs = lib.mkDefault 24;
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    environment.pathsToLink = [
      "/share/nix-direnv"
    ];
}
