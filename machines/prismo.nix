{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/systemd.nix) ];

  imports = [
    ../hardware/asus-3900x.nix
    ../modules/remote-luks-unlock.nix
    ../users/patrickod.nix
    ../modules/defaults.nix
  ];

  nix.trustedUsers = [ "@wheel" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "control" ];
    ensureUsers = [
      {
        name = "patrickod";
        ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.mpd = {
    enable = true;
    user = "patrickod";
    musicDirectory = "/mnt/media/audio/beets-export";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "pipewire"
      }

      # Enable replay gain.
      replaygain          "track"
    '';
  };

  ## necessary to resolve permissions issues between MPD & pipewire
  systemd.services.mpd.environment = { XDG_RUNTIME_DIR = "/run/user/1000"; };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = [ pkgs.xfce.thunar pkgs.nodejs ];

  # sops secret import for encrypted backups
  sops.defaultSopsFile = ../secrets/prismo.yml;
  sops.age.keyFile = "/etc/sops/age/keys.txt";
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
      [ "--exclude-file=/home/patrickod/.restic-backup-exclude" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-hourly 72"
      "--keep-daily 90"
      "--keep-weekly 52"
      "--keep-monthly 60"
      "--keep-yearly 50"
    ];
  };

  nix.settings.system-features =
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

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "22.05"; # Did you read the comment?
}
