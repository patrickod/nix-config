self: super: {
  systemd = super.systemd.overrideAttrs (prev: {
    mesonFlags = prev.mesonFlags ++ [ "-Ddefault-hierarchy=hybrid" ];
  });
}
