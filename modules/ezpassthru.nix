# Original from @notgne2 https://gist.github.com/notgne2/2563301b4b37b18335f20d4b2b026a12

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ezpassthru;
in
{
  options.services.ezpassthru = {
    enable = mkEnableOption "Enable simple VM PCI passthrough config (NOTE: this is only for ppl with a primary AMD/Intel, and a non-primary NVidia)";

    PCIs = mkOption {
      description = "The ID pairs of your PCI devices to passthrough";
      example = {
        "10de:1b80" = "0000:41:00.0";
        "10de:10f0" = "0000:41:00.1";
        "1022:43ba" = "0000:01:00.0";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    boot.extraModprobeConfig = "options vfio-pci ids=${builtins.concatStringsSep "," (builtins.attrNames cfg.PCIs)}";

    boot.postBootCommands = ''
    DEVS="${builtins.concatStringsSep " " (builtins.attrValues cfg.PCIs)}"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    '';
  };
}
