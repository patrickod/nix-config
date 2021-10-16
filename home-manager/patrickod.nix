{ config, pkgs, ... }:

{
  # home-manager setup
  home.username = "patrickod";
  home.homeDirectory = "/home/patrickod";
  home.sessionVariables = {
    "PATH" = "$HOME/.yarn/bin:$PATH";
  };
  home.stateVersion = "21.11";

  # dotfiles
  home.file.".spacemacs".source = ../dotfiles/spacemacs;
  home.file.".urxvt/ext/font-size".source =
    "${pkgs.urxvt_font_size}/lib/urxvt/perl/font-size";
  home.file.".config/nix/nix.conf".source = ../dotfiles/nix.conf;

  ## i3 status & keybinding configuration
  ## TODO: migrate to home-manager i3 configuration management
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config;

  # default packages
  home.packages = [
    pkgs.discord
    pkgs.feh
    pkgs.firefox
    pkgs.flyctl
    pkgs.fzf
    pkgs.gist
    pkgs.gnome3.nautilus
    pkgs.go
    pkgs.google-chrome-beta
    pkgs.htop
    pkgs.httpie
    pkgs.hwloc
    pkgs.iftop
    pkgs.iotop
    pkgs.jq
    pkgs.keychain
    pkgs.light
    pkgs.magic-wormhole
    pkgs.maim
    pkgs.mdbook
    pkgs.nix-index
    pkgs.nix-prefetch-github
    pkgs.nix-query-tree-viewer
    pkgs.nixUnstable
    pkgs.paperwork
    pkgs.patchelf
    pkgs.pavucontrol
    pkgs.pcmanfm
    pkgs.pigz
    pkgs.probe-run
    pkgs.restic
    pkgs.rustup
    pkgs.scrot
    pkgs.signal-desktop
    pkgs.silver-searcher
    pkgs.slack
    pkgs.unzip
    pkgs.urxvt_font_size
    pkgs.vlc
    pkgs.vscode
    pkgs.weechat
    pkgs.wireguard
    pkgs.xclip
    pkgs.zoxide
  ];

  xresources.properties = {
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
    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "main";
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

      # add cargo & ~/bin to path
      export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"

      # pyenv initialization
      export PATH="$HOME/.pyenv/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
      eval "$(pyenv virtualenv-init -)"

      # rbenv initialization
      eval "$(rbenv init -)"

      # processing.org pretty fonts
      export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
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

  programs.home-manager.enable = true;

  programs.i3status-rust.enable = true;
  programs.autorandr.enable = true;

  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      geometry = "0x5-30+50";
      transparency = 10;
      frame_color = "#eceff1";
      font = "Jetbrains Mono 10";
    };
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

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  systemd.user = {
    timers = {
      dendron-backup = {
        Unit = {
          Description = "git commit & push dendron notes at end of every working day";
        };
        timerConfig = {
          OnCalendar = "0 17 * * 1-5";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
    services = {
      dendron-backup = {
        Unit = {
          Description = "git commit & backup dendron notes every working day";
        };
        Service = {
          Script = ''
            ${pkgs.bash}/bin/bash
            cd /home/patrickod/code/notes
            git commit -am "eod commit $(date +'%F')"
            git push github oso
          '';
        };
        Install = {
          WantedBy = ["multi-user.target"];
        };
      };
    };
  };
}
