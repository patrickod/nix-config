{ config, lib, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/systemd.nix) ];

  imports = [
    ../hardware/asus-3900x.nix
    ../users/patrickod.nix
    ../modules/defaults.nix
    ../modules/qemu-hooks.nix
  ];

  specialisation = {
    work.configuration = {
      boot.kernelParams =
        [ "amd_iommu=on" "iommu=pt" "pcie_aspm=off" "video=efifb:off" ];
      services.ezpassthru.PCIs = {
        "10de:128b" = "0000:0c:00.0"; # GE710 Video
        "10de:0e0f" = "0000:0c:00.1"; # GE710 Audio
        "10de:2204" = "0000:05:00.0"; # RTX3090 Video
        "10de:1aef" = "0000:05:00.1"; # RTX3090 Audio
      };
    };
  };

  nix.systemFeatures =
    [ "big-parallel" "benchmark" "nixos-test" "kvm" "gccarch-znver2" ];

  # hostname + networking setup
  networking.hostName = "prismo"; # Define your hostname.
  networking.useDHCP = false;
  networking.bridges.br0.interfaces = [ "enp7s0" ];
  networking.interfaces.br0.useDHCP = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    monitorSection = ''
      DisplaySize 598 366
      Option "PreferredMode" "2560x1440"
    '';
    deviceSection = ''
      Option	"UseEdidDpi" "false"
    '';
    screenSection = ''
      Option         "metamodes" "2560x1440 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
      SubSection "Display"
        Modes "2560x1440"
      EndSubSection
    '';
  };

  # Configure NFS mounts for backups & photos
  fileSystems."/mnt/backups" = {
    device = "alexandria.lan:/mnt/alexandria/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/photos" = {
    device = "alexandria.lan:/mnt/alexandria/photos";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/media" = {
    device = "alexandria.lan:/mnt/alexandria/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  # Configure KVM
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemuVerbatimConfig = ''
      cgroup_device_acl = [
        "/dev/null",
        "/dev/full",
        "/dev/zero",
        "/dev/random",
        "/dev/urandom",
        "/dev/ptmx",
        "/dev/kvm",
        "/dev/kqemu",
        "/dev/rtc",
        "/dev/hpet",
        "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse",
        "/dev/input/by-id/usb-Kinesis_Freestyle_Edge_Keyboard_223606797749-if01-event-kbd",
        "/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd",
      ]
      namespaces = []
    '';
  };
  users.users.qemu-libvirtd.extraGroups = [ "input" ];

  # configure Looking Glass working file
  systemd.tmpfiles.rules =
    [ "f /dev/shm/looking-glass 0660 patrickod qemu-libvirtd -" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
