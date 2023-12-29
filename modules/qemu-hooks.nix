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

  win10Setup = pkgs.writeShellScript "win10_setup" ''
    HUGEPAGES=12288

    echo "Allocating hugepages..."
    echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
    ALLOC_PAGES="$(cat /proc/sys/vm/nr_hugepages)"

    TRIES=0
    while (( "$ALLOC_PAGES" != "$HUGEPAGES" && $TRIES < 1000 ))
    do
        echo 1 > /proc/sys/vm/compact_memory            ## defrag ram
        echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
        ALLOC_PAGES="$(cat /proc/sys/vm/nr_hugepages)"
        echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES"
        let TRIES+=1
    done

    if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
    then
        echo "Not able to allocate all hugepages. Reverting..."
        echo 0 > /proc/sys/vm/nr_hugepages
        exit 1
    fi

    # create VM slice & apply IRQ mask to guest cores
    vfio-isolate -u /tmp/vfio-isolate-undo \
        cpuset-create --cpus C0-2,12-14 /host.slice \
        cpuset-create --cpus C3-5,6-11,15-23 -nlb /machine.slice \
        irq-affinity mask C3-5,6-11,15-23 \
        cpu-governor performance C3-5,6-11,15-23 \
        move-tasks / /host.slice
  '';

  win10Teardown = pkgs.writeShellScript "win10_teardown" ''
    echo 0 > /proc/sys/vm/nr_hugepages
    echo "Released hugepages"
    vfio-isolate restore /tmp/vfio-isolate-undo
  '';
in
{

  systemd.services.swtpm = {
    description = "SWTPM implementation for QEMU VM";
    serviceConfig = {
      ExecStart =
        "${pkgs.swtpm-tpm2}/bin/swtpm socket --tpmstate dir=/var/lib/swtpm-localca --ctrl type=unixio,path=/var/lib/swtpm-localca/swtpm-sock";
      User = "qemu-libvirtd";
      Group = "qemu-libvirtd";
    };
    wantedBy = [ "libvirtd.service" ];
  };

  systemd.services.libvirtd = {
    path = with pkgs; [
      libvirt
      procps
      utillinux
      doas
      gawk
      vfio-isolate
      swtpm-tpm2
    ];
    preStart = ''
      mkdir -p /var/lib/libvirt/vbios
      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win10-{steam,intercom,steam-21H1}/{prepare/begin,release/end}

      ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
      for dest in /var/lib/libvirt/hooks/qemu.d/win10-{steam,intercom,steam-21H1}/prepare/begin/start.sh; do
        ln -sf ${win10Setup} $dest
      done
      for dest in /var/lib/libvirt/hooks/qemu.d/win10-{steam,intercom,steam-21H1}/release/end/revert.sh; do
        ln -sf ${win10Teardown} $dest
      done
    '';
  };
}
