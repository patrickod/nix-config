{ config, pkgs, ... }:

{
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

  home.packages = [
    pkgs.discord
    pkgs.firefox
    pkgs.feh
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
    pkgs.patchelf
    pkgs.pavucontrol
    pkgs.paperwork
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
  ];
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

      export PATH="$HOME/bin:$PATH"

      # pyenv initialization
      export PATH="$HOME/.pyenv/bin:$PATH"

      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
      eval "$(pyenv virtualenv-init -)"

      # rbenv initialization
      eval "$(rbenv init -)"
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
    "PATH" = "$HOME/.yarn/bin:$PATH";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "patrickod";
  home.homeDirectory = "/home/patrickod";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  home.file.".spacemacs".source = ../dotfiles/spacemacs;
  home.file.".urxvt/ext/font-size".source =
    "${pkgs.urxvt_font_size}/lib/urxvt/perl/font-size";

  ## i3 status & keybinding configuration
  ## TODO: migrate to home-manager i3 configuration management
  xdg.configFile."i3/status.toml".source = ../dotfiles/i3status-rs.toml;
  xdg.configFile."i3/config".source = ../dotfiles/i3-config;

  programs.i3status-rust.enable = true;
  programs.autorandr.enable = true;

  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      geometry = "0-10+33";
      transparency = 10;
      font = "Jetbrains Mono 12";
    };
  };

}
