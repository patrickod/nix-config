{ lib, ... }: {
  boot.initrd.availableKernelModules = [ "r8169" "realtek" ];
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 1022;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNw1fiUqzoc1HizXt54asUffQ/z0oQU/j5FKLf4371i patrickod@finn"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKzouQYFOdgBny9tcxuMSVrSq4lc7myv9BxGOy6mDKQ patrickod@marceline"
    ];
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
}
