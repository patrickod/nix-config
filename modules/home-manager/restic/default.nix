{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.restic-home-backup;

in {
  options = {
    services.restic-home-backup = {
      enable = mkOption {
        default = false;
        description = ''
          Enable restic /home backup.
        '';
      };
      repository = mkOption {
        default = "rest:http://pb:8080/";
        description = ''
          The restic repository destination for snapshot storage. (default pb over wireguard).
        '';
      };
      excludeFile = mkOption {
        default = "/home/patrickod/.restic-backup-exclude";
        description = ''
          List of file/folder patterns to ignore when backing up /home
        '';
      };
      passwordFile = mkOption {
        default = "/home/patrickod/.restic-backup-password";
        description = ''
          The passwordFile containing the backup key to pass to restic.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.timers."restic-home-backup" = {
      Unit = { Description = "backup /home with restic"; };

      Timer = {
        OnCalendar = "hourly";
        Persistent = true;
        Unit = "restic-home-backup.service";
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };

    systemd.user.services."restic-home-backup" = {
      Unit = { Description = "restic /home backup"; };

      Service = {
        Type = "oneshot";
        ExecStart =
          "${pkgs.restic}/bin/restic --repo ${cfg.repository} --password-file ${cfg.passwordFile} --exclude-file ${cfg.excludeFile} backup /home";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
