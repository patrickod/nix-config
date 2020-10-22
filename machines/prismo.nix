{ config, pkgs, lib, ... }:

{
  imports = [
    ../hardware/asus-3900x.nix
    ../secrets.nix
    <home-manager/nixos>
    ../users/patrickod.nix
  ];

  # change power button to suspend
  services.acpid.powerEventCommands = ''
    systemctl suspend
  '';

  nix.systemFeatures = ["big-parallel" "benchmark" "nixos-test" "kvm" "gccarch-znver2"];

  # hostname + networking setup
  networking.hostName = "prismo"; # Define your hostname.
  networking.useDHCP = false;
  networking.bridges.br0.interfaces = ["enp6s0"];
  networking.interfaces.br0.useDHCP = true;

  # remotely accessible by SSH
  services.openssh.enable = true;

  # set NOPASSWD sudoers
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  hardware.pulseaudio.extraConfig = ''
    # Local QEMU socket
    load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse
  '';

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = ["nvidia"];
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

  # Configure NFS mounts
  fileSystems."/mnt/backups" = {
    device = "alexandria.lan:/mnt/alexandria/backups";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
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
      ]
      namespaces = []
    '';
  };
  users.users.qemu-libvirtd.extraGroups = ["input"];

  # Configure dynamic hugepages for Win10-steam VM
  # TODO: abstract VM name & hugepage configurations for multi-VM work|gaming
  systemd.services.libvirtd.preStart = ''
    mkdir -p /var/lib/libvirt/hooks/win10-steam/{prepare/begin,release/end}
    chmod 755 /var/lib/libvirt/hooks/win10-steam/{prepare/begin,release/end}

    cat >/var/lib/libvirt/hooks/win10-steam/prepare/begin/alloc_hugepages.sh <<EOF
      HUGEPAGES=8192

      echo "Allocating hugepages..."
      echo \$HUGEPAGES > /proc/sys/vm/nr_hugepages
      ALLOC_PAGES=\$(cat /proc/sys/vm/nr_hugepages)

      TRIES=0
      while (( \$ALLOC_PAGES != \$HUGEPAGES && \$TRIES < 1000 ))
      do
          echo 1 > /proc/sys/vm/compact_memory            ## defrag ram
          echo 8192 > /proc/sys/vm/nr_hugepages
          ALLOC_PAGES=\$(cat /proc/sys/vm/nr_hugepages)
          echo "Succesfully allocated \$ALLOC_PAGES / \$HUGEPAGES"
          let TRIES+=1
      done

      if [ "\$ALLOC_PAGES" -ne "\$HUGEPAGES" ]
      then
          echo "Not able to allocate all hugepages. Reverting..."
          echo 0 > /proc/sys/vm/nr_hugepages
          exit 1
      fi
    EOF

    cat >/var/lib/libvirt/hooks/win10-steam/release/end/dealloc_hugepages.sh <<EOF
      echo 0 > /proc/sys/vm/nr_hugepages
    EOF

    chmod +x /var/lib/libvirt/hooks/win10-steam/prepare/begin/alloc_hugepages.sh
    chmod +x /var/lib/libvirt/hooks/win10-steam/release/end/dealloc_hugepages.sh
  '';
  systemd.services.libvirt.path = with pkgs; [
    bash
    gawk
  ];

  # configure Looking Glass working file
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 patrickod qemu-libvirtd -"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
