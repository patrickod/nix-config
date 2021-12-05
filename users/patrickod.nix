{ config, pkgs, ... }:

{
  imports = [ ../modules/polkit-allow-mount.nix ];

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
    hashedPassword =
      "$6$t1qPJ.r2M2XljH$dIBeXMWkq10Pr5C0FsSx44RxXzcxTXaK4.ULeYZ8UmFI8PuNWww5SAci2Zx.WTU4prUS775MuhkbMCg98dT.P0";
  };

  # Configure home-manager with user packages
  home-manager.users.patrickod = { pkgs, ... }: {
    home.packages = with pkgs; [
      _1password-gui
      cargo
      discord
      exa
      fd
      firefox-beta-bin
      flyctl
      fzf
      gist
      gmailieer
      go
      google-chrome-beta
      htop
      httpie
      hwloc
      iftop
      inkscape
      iotop
      jq
      keychain
      magic-wormhole
      maim
      mdbook
      nixfmt
      nix-index
      nix-prefetch-github
      notmuch
      paperwork
      obs-studio
      patchelf
      pavucontrol
      pcmanfm
      pigz
      probe-run
      processing
      restic
      scrot
      signal-desktop
      silver-searcher
      slack
      unzip
      urxvt_font_size
      vlc
      vscode
      weechat
      wireguard
      zoom-us
      xclip
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
        "font" = "xft:JetBrains Mono:pixelsize=12";
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
      startAgent = true;
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
    home.file.".urxvt/ext/font-size".source =
      "${pkgs.urxvt_font_size}/lib/urxvt/perl/font-size";

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
    ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", ENV{ID_SECURITY_TOKEN}="1"

    # MCP2221
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d8", ATTR{idProduct}=="00dd", MODE="0666"
  '';

}
