self: super: {
  nixUnstable =
    super.nixUnstable.override { patches = [ ../patches/nix-ismacho.patch ]; };
}
