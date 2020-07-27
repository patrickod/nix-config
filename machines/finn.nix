
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware/x260.nix
      ../secrets.nix
      <home-manager/nixos>
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "finn"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = false;
  networking.interfaces.wlp4s0.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
    dhcp
    direnv
    emacs
    git
    hwloc
    pciutils
    prometheus-node-exporter
    silver-searcher
    sqlite
    usbutils
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

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkbVariant = "dvorak";
    xkbOptions = "caps:escape,grp:shifts_toggle";
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
    extraGroups = [ "wheel" "docker" "video" ]; # Enable ‘sudo’ for the user.
  };

  programs.ssh.startAgent = true;

  # Configure home-manager with user packages
  home-manager.users.patrickod = { pkgs, ... }: {
    home.packages = [
      pkgs.arduino-core
      pkgs.awscli
      pkgs.bundix
      pkgs.discord
      pkgs.docker
      pkgs.firecracker
      pkgs.gist
      pkgs.go
      pkgs.google-chrome-beta
      pkgs.htop
      pkgs.httpie
      pkgs.hue-cli
      pkgs.hwloc
      pkgs.iftop
      pkgs.iotop
      pkgs.jq
      pkgs.keychain
      pkgs.magic-wormhole
      pkgs.maim
      pkgs.nix-prefetch-github
      pkgs.pavucontrol
      pkgs.pigz
      pkgs.restic
      pkgs.scrot
      pkgs.silver-searcher
      pkgs.slack
      pkgs.spotify
      pkgs.unzip
      pkgs.vlc
      pkgs.weechat
      pkgs.wireguard
      pkgs.xclip
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
      initExtra = ''
        eval "$(direnv hook zsh)"
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
    xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.finn.toml;
    xdg.configFile."i3/config".source = ../dotfiles/i3-config;
  };

  # Configure KVM
  # udev rules for programming keyboard
  services.udev.extraRules = ''
    # For Kaleidoscope/Keyboardio
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", TAG+="uaccess", TAG+="seat"
  '';

  # configure docker on host
  virtualisation.docker.enable = true;

  # enable lorri nix/direnv replacement
  services.lorri.enable = true;

  networking.firewall.enable = false;
  # # allow inbound TCP 1400 for Sonos hardware
  # networking.firewall.allowedTCPPortRanges = [
  #   { from = 1399; to = 1410; }
  # ];

  system.stateVersion = "20.03"; # Did you read the comment?

}
