{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;

  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages ([
        sdk_8_0
        sdk_9_0
      ]) + "/share/dotnet";

      EDITOR = "emacsclient";

      # force enable wayland
      # NIXOS_OZONE_WL = 1;

      NIRI_CONFIG = "/etc/nixos/dotfiles/niri/config.kdl";

      # Setting this to compile rust-openssl
      PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
    };
  };

  # # Copy paste between X windows
  services.clipcat.enable = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.picom = {
    enable = false;
    vSync = true;
    backend = "egl";
    settings = {
      unredir-if-possible = true;
      unredir-if-possible-exclude = [
        "_NET_WM_BYPASS_COMPOSITOR@:c = 2"
      ];
    };
  };

  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    rofi-wayland
    alacritty
    nemo
    xwayland-satellite
    wayland-utils
    wl-clipboard
    waypipe
  ];

  # Give EXWM permission to control the session.
  services.xserver.windowManager = {
    session = lib.singleton {
      name = "exwm";
      start = "/run/current-system/sw/bin/emacs";
    };
  };
  services.xserver.displayManager = {
    sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
  };

  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.gdm.enable = true;
  # programs.xwayland.enable = true;
  # programs.niri.enable = true;

  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;
  # services.desktopManager.cosmic.xwayland.enable = true;

  # Keyboard options
  services.xserver.xkb.layout = "us,ru,no";
  services.xserver.xkb.options = "grp:caps_toggle";

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = false;
      naturalScrolling = true;
      accelSpeed = "0.3";
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
    };
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts
      jetbrains-mono
      font-awesome_6
    ];
  };

  programs.firefox.enable = true;
  programs.dconf.enable = true;

  # Lock laptop after sleeping
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.xsecurelock}/bin/xsecurelock";

  # Don't turn off laptop on close lid when on power
  # services.logind.lidSwitchExternalPower = "ignore";

  # Define a user account
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    alias k="kubectl"
    alias e="emacsclient"
    set fish_greeting ""
    eval (direnv hook fish)
    source (find '${pkgs.emacsPackages.vterm}' -name 'emacs-vterm.fish')
  '';

  users.defaultUserShell = pkgs.fish;

  users.extraUsers.ezemtsov = {
    extraGroups = [
      "wheel" # for sudo
      "vboxusers" # for virtualbox
      "networkmanager"
      "libvirtd" # for kvm
      "docker" # for containers
      "video" # for brightness ctrl
      "audio" # for musnix
    ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # # There two properties are important to align home-manager with
  # # global nixpkgs set.
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = false;
  # # home-manager.backupFileExtension = "backup";
  # home-manager.users.ezemtsov = { config, ... }: {
  #   home.stateVersion = "25.05";
  #   home.enableNixpkgsReleaseCheck = true;



  # #   # home.pointerCursor = {
  # #   #   name = "Bibata-Original-Classic";
  # #   #   x11.enable = true;
  # #   #   gtk.enable = true;
  # #   #   size = 32;
  # #   #   package = pkgs.bibata-cursors;
  # #   # };

  # #   # qt.enable = true;

  # #   # gtk = {
  # #   #   enable = true;
  # #   #   theme.name = "Breeze-Dark";
  # #   #   cursorTheme.name = "Bibata-Original-Classic";
  # #   # };

  # #   # programs.firefox.enable = true;

  # #   # # notifications
  # #   # services.dunst = {
  # #   #   enable = true;
  # #   #   settings = {
  # #   #     global = {
  # #   #       frame_color = "#808080";
  # #   #     };
  # #   #     urgency_normal = {
  # #   #       timeout = "5";
  # #   #       background = "#333333";
  # #   #     };
  # #   #   };
  # #   # };

  # #   # programs.waybar.enable = true;
  # #   # programs.waybar.systemd.enable = true;
  # #   # systemd.user.services.waybar.Unit.After = lib.mkForce [ "niri.service" ];

  # #   xdg = {
  # #   #   portal = {
  # #   #     enable = true;
  # #   #     extraPortals = with pkgs; [
  # #   #       xdg-desktop-portal-gtk
  # #   #       xdg-desktop-portal-gnome
  # #   #       xdg-desktop-portal-wlr
  # #   #     ];
  # #   #     config.common.default = [ "*" ];
  # #   #   };
  # #     desktopEntries.dired = {
  # #       type = "Application";
  # #       name = "emacs-dired";
  # #       exec = "emacsclient %f";
  # #     };
  # #   #   mimeApps = {
  # #   #     enable = true;
  # #   #     defaultApplications = {
  # #   #       "inode/directory" = "emacs-dired.desktop";
  # #   #       "text/html" = "firefox.desktop";
  # #   #     };
  # #   #   };
  # #   #   configFile."waybar/config".source = ./dotfiles/waybar/config;
  # #   #   configFile."waybar/style.css".source = ./dotfiles/waybar/style.css;
  # #   #   configFile."rofi/config.rasi".source = ./dotfiles/rofi/config.rasi;
  # #   };

  #   services.grobi =
  #     let external = [ "HDMI-1" ] ++ map (i: "DP-${toString i}") (lib.lists.range 1 9);
  #     in {
  #       enable = true;
  #       rules = map
  #         (o: {
  #           name = o;
  #           outputs_connected = [ o ];
  #           configure_single = o;
  #           primary = true;
  #         })
  #         external ++ [{
  #           name = "eDP-1";
  #           outputs_disconnected = external;
  #           configure_single = "eDP-1";
  #           primary = true;
  #         }];
  #     };

  # #   programs.i3status-rust.enable = true;
  # #   programs.i3status-rust.bars.default = {
  # #     blocks = [
  # #       { block = "net"; format = " $icon {$signal_strength $ssid} "; }
  # #       { block = "disk_space"; format = " $available.eng(w:2) "; }
  # #       { block = "sound"; format = " $volume.eng(w:2) "; }
  # #       { block = "time"; interval = 60; }
  # #       { block = "custom"; persistent = true; command = "${pkgs.xkbmon}/bin/xkbmon -u"; }
  # #       { block = "battery"; }
  # #     ];
  # #     icons = "awesome6";
  # #     settings.theme.overrides = {
  # #       idle_bg = "#282A2E";
  # #       good_bg = "#282A2E";
  # #       warning_bg = "#282A2E";
  # #       critical_bg = "#282A2E";
  # #       info_bg = "#282A2E";
  # #       separator_bg = "#282A2E";
  # #     };
  # #   };
  # };
}
