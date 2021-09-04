{ config, pkgs, ... }:

{
  imports = [
    ../modules/polkit-allow-mount.nix
  ];

  # allow use of non-free packages
  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  #environment.pathsToLink = [ "/share/nix-direnv" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dhcp
    emacs
    git
    hwloc
    pciutils
    prometheus-node-exporter
    keychain
    pv
    silver-searcher
    sqlite
    systool
    usbutils
    vim
    wget
    xorg.xdpyinfo
    swtpm-tpm2
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
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "dvorak";
    xkbOptions = "caps:escape";

    inputClassSections = [
      ''
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

      ''
    ];

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";

      autoLogin.enable = true;
      autoLogin.user = "patrickod";

      lightdm = {
        enable = true;
        greeter.enable = false;
      };

      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <${
          pkgs.writeText "Xresources" ''
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
          ''
        }
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
        feh
      ];
    };
  };

  fonts.fonts = with pkgs; [
    source-code-pro
    proggyfonts
    font-awesome
    jetbrains-mono
    font-awesome-ttf
    font-awesome
    font-awesome_4
  ];

  users.users.patrickod = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" "dialout" "audio" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$t1qPJ.r2M2XljH$dIBeXMWkq10Pr5C0FsSx44RxXzcxTXaK4.ULeYZ8UmFI8PuNWww5SAci2Zx.WTU4prUS775MuhkbMCg98dT.P0";
  };

  programs.ssh.startAgent = true;
  programs.zsh.enable = true;

  # Configure home-manager with user packages
  home-manager.users.patrickod = { pkgs, ... }: {
    home.packages = with pkgs; [
      _1password-gui
      acpi
      bitwig-studio3
      cargo
      discord
      eagle
      exa
      fd
      firefox-beta-bin
      flyctl
      fzf
      gist
      gmailieer
      gnome3.nautilus
      go
      google-chrome-beta
      htop
      httpie
      hwloc
      iftop
      iotop
      ispell
      jq
      keychain
      magic-wormhole
      maim
      mdbook
      nixfmt
      nix-index
      nix-prefetch-github
      notmuch
      openscad
      paperwork
      patchelf
      pavucontrol
      pcmanfm
      pigz
      probe-run
      restic
      scrot
      signal-desktop
      silver-searcher
      slack
      unzip
      urxvt_font_size
      vcv-rack
      vlc
      vscode
      weechat
      wireguard
      xclip
      zeal
      zoom-us
    ];
    programs.git = {
      enable = true;
      userName = "Patrick O'Doherty";
      userEmail = "p@trickod.com";
      extraConfig = {
        pull.ff = "only";
        init.defaultBranch = "main";
        core.editor = "emacsclient -c";
      };
    };
    programs.zsh = {
      enable = true;
      history.extended = true;
      oh-my-zsh = {
        enable = true;
        theme = "dieter";
        plugins = [ "git" ];
      };
      initExtra = ''
        export TERM=xterm-256color
        eval `keychain --eval id_ed25519 iocoop`
      '';
    };
    programs.urxvt = {
      enable = true;
      transparent = true;
      shading = 20;
      extraConfig = {
        "font" = "xft:JetBrains Mono:pixelsize=14";
        "perl-ext-common" = "font-size";
        "keysym.C-Up" = "font-size:increase";
        "keysym.C-Down" = "font-size:decrease";
        "keysym.C-S-Up" = "font-size:incglobal";
        "keysym.C-S-Down" = "font-size:decglobal";
        "keysym.C-equal" = "font-size:reset";
        "keysym.C-slash" = "font-size:show";
      };
    };
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "betty.patrickod.com" = { user = "root"; };
        "g1-*" = {
          user = "root";
          certificateFile = "~/.ssh/iocoop-cert.pub";
          proxyCommand = "ssh manage1.scl.iocoop.org nc %h %p";
        };
      };
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      nix-direnv.enableFlakes = true;
      enableZshIntegration = true;
    };
    services.redshift = {
      enable = true;
      latitude = "37.7749";
      longitude = "-122.4194";
      brightness.day = "1";
      brightness.night = "0.85";
      temperature.night = 3900;
      tray = true;
    };

    home.sessionVariables = {
      BROWSER = "${pkgs.google-chrome-beta}/bin/google-chrome-beta";
    };

    home.file.".spacemacs".source = ../dotfiles/spacemacs;
    home.file.".notmuch-config".source = ../dotfiles/notmuch-config;
    home.file.".urxvt/ext/font-size".source = "${pkgs.urxvt_font_size}/lib/urxvt/perl/font-size";


    ## i3 status & keybinding configuration
    ## TODO: migrate to home-manager i3 configuration management
    xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
    xdg.configFile."i3/config".source = ../dotfiles/i3-config;

    # configure nixpkgs to allow unfree etc...
    home.file.".config/nixpkgs/config.nix".source =
      ../dotfiles/nixpkgs-config.nix;
  };

  # udev rules for programming keyboard & axoloti
  services.udev.extraRules = ''
    # For Kaleidoscope/Keyboardio
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"

    # For Axoloti
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0442", OWNER="patrickod", GROUP="users"

    # Adafruit Feathers
    ATTRS{idVendor}=="239a", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", MODE="0666"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="239a", MODE="0666"

    # STLink-V2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", GROUP="dialout"

    # Yubikey
    ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", ENV{ID_SECURITY_TOKEN}="1", TAG+="uaccess"

    # MCP2221
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d8", ATTR{idProduct}=="00dd", MODE="0666"
  '';

  services.syncthing = {
    enable = true;
    user = "patrickod";
    dataDir = "/home/patrickod/syncthing";
    configDir = "/home/patrickod/.config/syncthing/";
  };
}
