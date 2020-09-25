{ config, pkgs, ... }:

{
    # allow use of non-free packages
    nixpkgs.config.allowUnfree = true;

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak";
    };

    time.timeZone = "America/Los_Angeles";
    time.hardwareClockInLocalTime = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      dhcp
      direnv
      emacs
      git
      hwloc
      pciutils
      prometheus-node-exporter
      pv
      silver-searcher
      sqlite
      systool
      usbutils
      vim
      wget
      xorg.xdpyinfo
    ];

    services.gnome3.gnome-keyring.enable = true;

    # configure default editor
    services.emacs.enable = true;
    environment.variables = {
      EDITOR = "emacsclient -c";
      VISUAL = "emacsclient -c";
      LIBVIRT_DEFAULT_URI = "qemu:///system";
      NIXPKGS = "/home/patrickod/code/nixpkgs";
    };

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      layout = "dvorak";
      xkbOptions = "caps:escape";

      inputClassSections = [''
        Identifier "keyboardio"
        MatchIsKeyboard "on"
        MatchProduct "Keyboardio"

        Option "XkbLayout" "us"
      ''
      ''
        Identifier "advantage"
        MatchIsKeyboard "on"
        MatchProduct "05f3"

        Option "XkbLayout" "us"

      ''];

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
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

    users.users.patrickod = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" "dialout"];
      shell = pkgs.zsh;
    };

    programs.ssh.startAgent = true;
    programs.zsh.enable = true;

    # Configure home-manager with user packages
    home-manager.users.patrickod = { pkgs, ... }: {
      home.packages = [
        pkgs.arduino-core
        pkgs.awscli
        pkgs.axoloti
        pkgs.bundix
        pkgs.discord
        pkgs.docker
        pkgs.docker-compose
        pkgs.eagle
        pkgs.esphome
        pkgs.firecracker
        pkgs.firefox
        pkgs.gist
        pkgs.go
        pkgs.google-chrome-beta
        pkgs.htop
        pkgs.httpie
        pkgs.hwloc
        pkgs.iftop
        pkgs.iotop
        pkgs.jq
        pkgs.keychain
        pkgs.kicad-unstable
        pkgs.magic-wormhole
        pkgs.maim
        pkgs.gnome3.nautilus
        pkgs.nixops
        pkgs.nix-prefetch-github
        pkgs.nix-query-tree-viewer
        pkgs.nixops
        pkgs.nix-prefetch-github
        pkgs.pavucontrol
        pkgs.pcmanfm
        pkgs.pigz
        pkgs.probe-run
        pkgs.restic
        pkgs.rustup
        pkgs.scrot
        pkgs.silver-searcher
        pkgs.slack
        pkgs.spotify
        pkgs.unzip
        pkgs.vlc
        pkgs.vscode
        pkgs.weechat
        pkgs.wireguard
        pkgs.xclip
      ] ;
      programs.git = {
        enable = true;
        userName = "Patrick O'Doherty";
        userEmail = "p@trickod.com";
        extraConfig = {
          pull.ff = "only";
        };
      };
      programs.zsh = {
        enable = true;
        history.extended = true;
        oh-my-zsh = {
          enable = true;
          theme = "dieter";
          plugins = [
            "git"
          ];
        };
        initExtra = ''
          eval "$(direnv hook zsh)"
          export PATH=$HOME/.cargo/bin:$PATH
        '';
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

      home.file.".emacs.d" = {
        source = builtins.fetchGit {
          url = "https://github.com/syl20bnr/spacemacs";
          ref = "develop";
        };
        recursive = true;
      };
      home.file.".spacemacs".source = ../dotfiles/spacemacs;

      ## i3 status & keybinding configuration
      ## TODO: migrate to home-manager i3 configuration management
      xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
      xdg.configFile."i3/config".source = ../dotfiles/i3-config;
    };

    # udev rules for programming keyboard & axoloti
    services.udev.extraRules = ''
      # For Kaleidoscope/Keyboardio
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"

      # For Axoloti
      SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0442", OWNER="patrickod", GROUP="users"

      # For Adafruit EdgeBadge & PyGamer HF2
      ATTRS{idVendor}=="239a", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", MODE="0666"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="239a", MODE="0666"
    '';

    # configure docker on host
    virtualisation.docker.enable = true;

    # enable lorri nix/direnv replacement
    services.lorri.enable = true;
}
