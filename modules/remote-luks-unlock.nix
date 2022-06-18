{ lib, ... }: {
  boot.initrd.availableKernelModules = [ "r8169" "realtek" ];
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 1022;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0y01bFTQj57K1u9ZrVLPv45cwm8MFwLzRRm2U9vgOp patrickod@kimkilwhan"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNw1fiUqzoc1HizXt54asUffQ/z0oQU/j5FKLf4371i patrickod@finn"
    ];
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
}
