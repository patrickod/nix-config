{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/systemd.nix) ];

  imports = [
    ../hardware/asus-3900x.nix
    ../modules/remote-luks-unlock.nix
    ../users/patrickod.nix
    ../modules/defaults.nix
  ];

  nix.settings.trusted-users = [ "@wheel" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "control" ];
    ensureUsers = [{
      name = "patrickod";
      ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
    }];
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  hardware.xpadneo.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [ pinentry xfce.thunar nodejs libimobiledevice ifuse ];
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.sushi.enable = true;
  services.gnome.tracker.enable = true;
  services.gnome.tracker-miners.enable = true;

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

  age.secrets.restic_backup_password = {
    file = ../secrets/restic_backup_password.age;
    owner = "patrickod";
    group = "wheel";
    mode = "0440";
  };

  age.secrets.restic_r2_environment = {
    file = ../secrets/prismo_restic_r2_environment.age;
    owner = "patrickod";
    group = "wheel";
    mode = "0440";
  };

  services.restic.backups.home_r2 = {
    user = "patrickod";
    environmentFile = "/run/agenix/restic_r2_environment";
    repository = "s3:https://e69c83c6e2f046b0a79045a27333ffb4.r2.cloudflarestorage.com/restic";
    initialize = true;
    passwordFile = "/run/agenix/restic_backup_password";
    extraBackupArgs =
      [ "--exclude-file=/home/patrickod/.restic-backup-exclude" ];
    paths = [ "/home" ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 90"
      "--keep-weekly 52"
      "--keep-monthly 60"
      "--keep-yearly 50"
    ];
  };

  services.restic.backups.home = {
    user = "patrickod";
    repository = "/mnt/backups/prismo/restic";
    paths = [ "/home" ];
    initialize = true;
    passwordFile = "/run/agenix/restic_backup_password";
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

  programs.steam.enable = true;

  # Configure NFS mounts for backups & photos
  fileSystems."/mnt/backups" = {
    device = "192.168.4.37:/mnt/alexandria/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/photos" = {
    device = "192.168.4.37:/mnt/alexandria/photos";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/media" = {
    device = "192.168.4.37:/mnt/alexandria/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/torrents" = {
    device = "192.168.4.37:/mnt/alexandria/torrents";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  xdg.portal.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };

  services.usbmuxd.enable = true;
  services.flatpak.enable = true;


  system.stateVersion = "22.11"; # Did you read the comment?
}
