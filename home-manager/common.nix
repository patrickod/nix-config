{ home, config, pkgs, ... }:

{
  # home-manager setup
  home.username = "patrickod";
  home.homeDirectory = "/home/patrickod";
  home.sessionVariables = {
    "BROWSER" = "${pkgs.google-chrome-beta}/bin/google-chrome-beta";
  };
  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  # dotfiles
  home.file.".spacemacs".source = ../dotfiles/spacemacs;
  home.file.".urxvt/ext/font-size".source =
    "${pkgs.rxvt-unicode-plugins.font-size}/lib/urxvt/perl/font-size";
  home.file.".config/nix/nix.conf".source = ../dotfiles/nix.conf;

  # restic common backup exclusions
  home.file.".restic-backup-exclude".source = ../dotfiles/restic-backup-exclude;

  # default packages
  home.packages = [
    pkgs.act
    pkgs.age
    pkgs.cascadia-code
    # pkgs.discord
    pkgs.exa
    pkgs.emoji-picker
    pkgs.fd
    pkgs.feh
    pkgs.firefox
    pkgs.fzf
    pkgs.gdb
    pkgs.gist
    pkgs.git-history
    pkgs.glslang
    pkgs.go
    pkgs.google-chrome-beta
    pkgs.htop
    pkgs.httpie
    pkgs.hub
    pkgs.hwloc
    pkgs.iftop
    pkgs.inkscape
    pkgs.iotop
    pkgs.jq
    pkgs.keychain
    pkgs.light
    pkgs.magic-wormhole
    pkgs.maim
    pkgs.mdbook
    pkgs.ncmpcpp
    pkgs.nixfmt
    pkgs.nixpkgs-fmt
    pkgs.obs-studio
    pkgs.paperwork
    pkgs.patchelf
    pkgs.pavucontrol
    pkgs.pcmanfm
    pkgs.pigz
    pkgs.probe-run
    pkgs.rage
    pkgs.restic
    pkgs.rofi-pulse-select
    pkgs.rustup
    pkgs.scrot
    pkgs.signal-desktop
    pkgs.silver-searcher
    pkgs.sops
    pkgs.unzip
    pkgs.rxvt-unicode-plugins.font-size
    pkgs.vlc
    pkgs.weechat
    pkgs.xclip
    pkgs.yarn
    pkgs.zoxide
    pkgs.vscode
    pkgs.noisetorch
  ];

  services.redshift = {
    enable = true;
    settings = {
      brightness.day = "1";
      brightness.night = "0.85";
    };
    latitude = "37.7749";
    longitude = "-122.4194";
    temperature.night = 3900;
    tray = true;
  };

  xresources.properties = {
    "Emacs.font" = "JetBrains Mono:font=12";
    "URxvt*.foreground" = "#c5c8c6";
    "URxvt*.background" = "#1d1f21";
    "URxvt*.cursorColor" = "#c5c8c6";
    "URxvt*.color0" = "#282a2e";
    "URxvt*.color8" = "#373b41";
    "URxvt*.color1" = "#a54242";
    "URxvt*.color9" = "#cc6666";
    "URxvt*.color2" = "#8c9440";
    "URxvt*.color10" = "#b5bd68";
    "URxvt*.color3" = "#de935f";
    "URxvt*.color11" = "#f0c674";
    "URxvt*.color4" = "#5f819d";
    "URxvt*.color12" = "#81a2be";
    "URxvt*.color5" = "#85678f";
    "URxvt*.color13" = "#b294bb";
    "URxvt*.color6" = "#5e8d87";
    "URxvt*.color14" = "#8abeb7";
    "URxvt*.color7" = "#707880";
    "URxvt*.color15" = "#c5c8c6";
  };

  programs.git = {
    enable = true;
    userName = "Patrick O'Doherty";
    userEmail = "p@trickod.com";
    lfs.enable = true;
    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "main";
      core.editor = "vim";
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingKey = "~/.ssh/id_ed25519.pub";
    };
  };

  programs.zsh = {
    enable = true;
    history.extended = true;
    oh-my-zsh = {
      enable = true;
      theme = "dieter";
      plugins = [ "git" "fzf" "zoxide" "1password" "dotenv" ];
    };
    initExtra = ''
      export TERM=xterm-256color
      eval `keychain --eval id_ed25519`

      # add ~/.cargo/bin & ~/bin to path
      export PATH="$HOME/.cargo/bin:$HOME/bin:$PATH"

      # processing.org pretty fonts
      export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

      # use exa instead of ls
      alias ls="exa"

      # bump the history size to stop it truncating
      HISTSIZE=500000
      SAVEHIST=500000
      # write history entries immediately not at shell termination
      setopt appendhistory
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
    '';
  };

  services.picom.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 9;
    };
    theme = "Blazer";
    settings = {
      enable_audio_bell = false;
      background_opacity = "0.95";
      confirm_os_window_clase = -1;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,emoji";
    };
    plugins = [ pkgs.rofi-emoji pkgs.rofi-file-browser ];
    font = "JetBrains Mono 13";
  };

  # directory navigation with history
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.i3status-rust.enable = true;
  programs.autorandr.enable = true;

  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      geometry = "0x5-30+50";
      transparency = 10;
      frame_color = "#eceff1";
      font = "Jetbrains Mono 11";
    };
  };

  services.flameshot.enable = true;
  services.flameshot.settings = {
    General = {
      savePath = "/home/patrickod/screenshots";
      startupLaunch = true;
    };
  };

}
