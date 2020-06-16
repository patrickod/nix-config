{ config, pkgs, ... }:

{
  imports =
    [../hardware/asus-3900x.nix
     ../secrets.nix
     <home-manager/nixos>
    ];

    # allow use of non-free packages
    nixpkgs.config.allowUnfree = true;

    # hostname + networking setup
    networking.hostName = "prismo"; # Define your hostname.
    networking.useDHCP = false;
    networking.bridges.br0.interfaces = ["enp6s0"];
    networking.interfaces.br0.useDHCP = true;

    # remotely accessible by SSH
    services.openssh.enable = true;

    # set NOPASSWD sudoers
    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false;

    # keyboard funkiness and locale
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak";
    };

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";
    time.hardwareClockInLocalTime = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      emacs
      git
      looking-glass-client
      magic-wormhole
      pciutils
      prometheus-node-exporter
      scream-receivers
      silver-searcher
      vim
      wget
      xorg.xdpyinfo
    ];

    # configure default editor
    services.emacs.enable = true;
    environment.variables = {
      EDITOR = "emacsclient -c";
      VISUAL = "emacsclient -c";
    };

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # Enable U2F token support
    hardware.u2f.enable = true;

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "dvorak";
      xkbOptions = "caps:escape";
      videoDrivers = ["nvidia"];
      monitorSection = ''
        DisplaySize 598 366
        Option "PreferredMode" "2560x1440"
      '';
      deviceSection = ''
        Option	"UseEdidDpi" "false"
      '';
      screenSection = ''
        SubSection "Display"
        Modes "2560x1440"
        EndSubSection
      '';

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";

        lightdm = {
          enable = true;
          greeter.enable = false;
          autoLogin.enable = true;
          autoLogin.user = "patrickod";
        };

        sessionCommands = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
            ! hard contrast: *background: #1d2021
            *background: #282828
            ! soft contrast: *background: #32302f
            *foreground: #ebdbb2
            ! Black + DarkGrey
            *color0:  #282828
            *color8:  #928374
            ! DarkRed + Red
            *color1:  #cc241d
            *color9:  #fb4934
            ! DarkGreen + Green
            *color2:  #98971a
            *color10: #b8bb26
            ! DarkYellow + Yellow
            *color3:  #d79921
            *color11: #fabd2f
            ! DarkBlue + Blue
            *color4:  #458588
            *color12: #83a598
            ! DarkMagenta + Magenta
            *color5:  #b16286
            *color13: #d3869b
            ! DarkCyan + Cyan
            *color6:  #689d6a
            *color14: #8ec07c
            ! LightGrey + White
            *color7:  #a89984
            *color15: #ebdbb2
          ''}
        '';
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          rofi
          i3status-rust
          i3lock-fancy
          i3-gaps
          i3blocks
        ];
        };
    };

    fonts.fonts = with pkgs; [
      source-code-pro
      proggyfonts
      font-awesome
    ];

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.patrickod = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" ]; # Enable ‘sudo’ for the user.
    };

    # Configure home-manager with user packages
    home-manager.users.patrickod = { pkgs, ... }: {
      home.packages = [
        pkgs.awscli
        pkgs.discord
        pkgs.docker
        pkgs.firecracker
        pkgs.gist
        pkgs.go
        pkgs.google-chrome-beta
        pkgs.htop
        pkgs.httpie
        pkgs.hwloc
        pkgs.jq
        pkgs.maim
        pkgs.nix-prefetch-github
        pkgs.pavucontrol
        pkgs.scrot
        pkgs.slack
        pkgs.spotify
        pkgs.weechat
        pkgs.xclip
        pkgs.vlc
      ] ;
      programs.git = {
        enable = true;
        userName = "Patrick O'Doherty";
        userEmail = "p@trickod.com";
      };
      programs.zsh = {
        enable = true;
        history.extended = true;
        oh-my-zsh = {
        enable = true;
          theme = "dallas";
          plugins = [
            "git"
          ];
        };
      };
      programs.urxvt = {
        enable = true;
      };
      services.redshift = {
        enable = true;
        latitude = "37.7749";
        longitude = "-122.4194";
        brightness.day = "1";
        brightness.night = "0.7";
        tray = true;
      };

      home.sessionVariables = {
        BROWSER = "${pkgs.google-chrome-beta}/bin/google-chrome-beta";
      };
    };


    # Configure KVM
    virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemuVerbatimConfig = ''
    cgroup_device_acl = [
      "/dev/null",
      "/dev/full",
      "/dev/zero",
      "/dev/random",
      "/dev/urandom",
      "/dev/ptmx",
      "/dev/kvm",
      "/dev/kqemu",
      "/dev/rtc",
      "/dev/hpet",
      "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse",
      "/dev/input/by-id/usb-Kinesis_Freestyle_Edge_Keyboard_223606797749-if01-event-kbd",
    ]
    namespaces = []
    '';
    };
    users.users.qemu-libvirtd.extraGroups = ["input"];

    # configure docker on host
    virtualisation.docker.enable = true;

    # configure Looking Glass working file
    systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 alex qemu-libvirtd -"
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "20.03"; # Did you read the comment?
}
