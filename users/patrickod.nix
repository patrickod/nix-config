{ config, pkgs, ... }:

{
  imports = [ ../modules/polkit-allow-mount.nix ];

  programs.zsh.enable = true;
  users.users.patrickod = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" "dialout" "audio" ];
    shell = pkgs.zsh;
    hashedPassword =
      "$6$t1qPJ.r2M2XljH$dIBeXMWkq10Pr5C0FsSx44RxXzcxTXaK4.ULeYZ8UmFI8PuNWww5SAci2Zx.WTU4prUS775MuhkbMCg98dT.P0";

    openssh = {
      authorizedKeys = {
        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnVbaP3o6F5ri9NMS+oAoZ6GlEq7h5XRAe9pgGJBnsg patrickod@prismo"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNw1fiUqzoc1HizXt54asUffQ/z0oQU/j5FKLf4371i patrickod@finn"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0y01bFTQj57K1u9ZrVLPv45cwm8MFwLzRRm2U9vgOp patrickod@kimkilwhan"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5KnJSwhuKtaaqVzoQKmnJIddfTJRhzYqLVze6NgFgq patrickod@ipad"
        ];
      };
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    brightnessctl
    emacs
    git
    hwloc
    pciutils
    prometheus-node-exporter
    sqlite
    sysfsutils
    usbutils
    vim
    wget
  ];

  services.gnome.gnome-keyring.enable = true;

  # configure default editor
  environment.variables = { LIBVIRT_DEFAULT_URI = "qemu:///system"; };

  # fonts for system wide use
  fonts.fonts = with pkgs; [
    source-code-pro
    proggyfonts
    font-awesome
    jetbrains-mono
    arkpandora_ttf
    noto-fonts-emoji
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "caps:escape";

    inputClassSections = [
      ''
        Identifier "atreus"
        MatchIsKeyboard "on"
        MatchProduct "Keyboardio Atreus"
        DriveR "evdev"

        Option "XkbLayout" "us"
      ''
      ''
        Identifier "advantage"
        MatchIsKeyboard "on"
        MatchProduct "05f3"
        Driver "evdev"

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
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        rofi
        rofi-file-browser
        rofi-emoji
        rofi-calc
        i3status-rust
        i3lock-fancy
        i3-gaps
        i3blocks
        feh
      ];
    };
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

    # RTL-SDR
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", OWNER="patrickod"

    # 8BitDo Pro 2; Bluetooth; USB
    SUBSYSTEM=="input", ATTRS{name}=="8BitDo Pro 2", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess", OWNER="patrickod", GROUP="users"
    SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6003", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess", OWNER="patrickod", GROUP="users"
  '';

}
