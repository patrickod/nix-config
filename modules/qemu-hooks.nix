{ pkgs, ... }:

let
    qemuHook = pkgs.writeShellScript "qemu" ''
        #
        # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
        #
        # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
        # After this file is installed, restart libvirt.
        # From now on, you can easily add per-guest qemu hooks.
        # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
        # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
        #
        GUEST_NAME="$1"
        HOOK_NAME="$2"
        STATE_NAME="$3"
        MISC="''${@:4}"
        BASEDIR="$(dirname $0)"
        HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"
        set -e # If a script exits with an error, we should as well.
        # check if it's a non-empty executable file
        if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
            eval \"$HOOKPATH\" "$@"
        elif [ -d "$HOOKPATH" ]; then
            while read file; do
                # check for null string
                if [ ! -z "$file" ]; then
                eval \"$file\" "$@"
                fi
            done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
        fi
    '';

    allocHugepages = pkgs.writeShellScript "alloc_hugepages" ''
      HUGEPAGES=8192

      echo "Allocating hugepages..."
      echo \$HUGEPAGES > /proc/sys/vm/nr_hugepages
      ALLOC_PAGES="\$(cat /proc/sys/vm/nr_hugepages)"

      TRIES=0
      while (( \$ALLOC_PAGES != \$HUGEPAGES && \$TRIES < 1000 ))
      do
          echo 1 > /proc/sys/vm/compact_memory            ## defrag ram
          echo 8192 > /proc/sys/vm/nr_hugepages
          ALLOC_PAGES="\$(cat /proc/sys/vm/nr_hugepages)"
          echo "Succesfully allocated \$ALLOC_PAGES / \$HUGEPAGES"
          let TRIES+=1
      done

      if [ "\$ALLOC_PAGES" -ne "\$HUGEPAGES" ]
      then
          echo "Not able to allocate all hugepages. Reverting..."
          echo 0 > /proc/sys/vm/nr_hugepages
          exit 1
      fi
    '';


    deallocHugepages = pkgs.writeShellScript "dealloc_hugepages" ''
        cat >/var/lib/libvirt/hooks/win10-steam/release/end/dealloc_hugepages.sh <<EOF
        #!/usr/bin/env bash
        echo 0 > /proc/sys/vm/nr_hugepages
        echo "Released hugepages"
        EOF
    '';
in {
    systemd.services.libvirtd = {
        path = with pkgs; [ libvirt procps utillinux doas gawk ];
        preStart = ''
            mkdir -p /var/lib/libvirt/vbios
            mkdir -p /var/lib/libvirt/hooks
            mkdir -p /var/lib/libvirt/hooks/qemu.d/win10-steam/prepare/begin
            mkdir -p /var/lib/libvirt/hooks/qemu.d/win10-steam/release/end
            ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
            ln -sf ${allocHugepages} /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin/start.sh
            ln -sf ${deallocHugepages} /var/lib/libvirt/hooks/qemu.d/windows10/release/end/revert.sh
        '';
    };
}