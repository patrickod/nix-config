{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/systemd.nix) ];

  imports = [
    ../hardware/asus-3900x.nix
    ../modules/remote-luks-unlock.nix
    ../users/patrickod.nix
    ../modules/defaults.nix
    ../modules/qemu-hooks.nix
  ];

  services.espanso.enable = true;

  environment.systemPackages = [ pkgs.xfce.thunar ];

  # sops secret import for encrypted backups
  sops.defaultSopsFile = ../secrets/prismo.yml;
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/home/patrickod/.config/sops/age/keys.txt";
  sops.secrets.restic_backup_password = {
    mode = "0440";
    owner = "patrickod";
    group = "wheel";
  };

  services.restic.backups.home = {
    user = "patrickod";
    repository = "/mnt/backups/prismo/restic";
    paths = [ "/home" ];
    initialize = true;
    passwordFile = "/run/secrets/restic_backup_password";
    extraBackupArgs =
      [ "--exclude-file=/home/patrickod/.restic-backup-exclude"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-hourly 72"
      "--keep-daily 21"
      "--keep-weekly 52"
      "--keep-monthly 60"
      "--keep-yearly 50"
    ];
  };

  nix.systemFeatures =
    [ "big-parallel" "benchmark" "nixos-test" "kvm" "gccarch-znver2" ];

  # hostname + networking setup
  networking.hostName = "prismo";
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp6s0.wakeOnLan.enable = true;

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
    device = "172.30.42.20:/mnt/alexandria/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/photos" = {
    device = "172.30.42.20:/mnt/alexandria/photos";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/media" = {
    device = "172.30.42.20:/mnt/alexandria/media";
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

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
