{ lib, pkgs, ... }:

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

      # Use Emacs XIM for input methods
      GTK_IM_MODULE = "xim";
      QT_IM_MODULE = "xim";
    };
  };

  # # Copy paste between X windows
  services.clipcat.enable = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    rofi-wayland
    alacritty

    # EXWM packages
    i3status-rust
    flameshot
    grobi
    xclip
    xsecurelock
    nemo
    xwayland-satellite
    wayland-utils
    wl-clipboard
    waypipe
  ];


  # Configure EXWM
  services.xserver = {
    # Give EXWM permission to control the session.
    displayManager.sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
    windowManager = {
      session = lib.singleton {
        name = "exwm";
        start = ''/run/current-system/sw/bin/emacs \
          --init-directory /etc/nixos/dotfiles/emacs'';
      };
    };
  };

  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.gdm.enable = true;
  # programs.xwayland.enable = true;
  # programs.niri.enable = true;

  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;
  # services.desktopManager.cosmic.xwayland.enable = true;

  # Keyboard options
  services.xserver.xkb.layout = "us,ru,no,se";
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

  # Setup home-manager to reuse global channel
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.backupFileExtension = "backup";

  home-manager.users.ezemtsov = { config, ... }: {
    home.stateVersion = "25.05";
    home.enableNixpkgsReleaseCheck = false;

    services.picom.enable = true;
    services.picom.vSync = true;

    services.grobi =
      let external = [ "HDMI-1" ] ++ map (i: "DP-${toString i}") (lib.lists.range 1 9);
      in {
        enable = true;
        rules = map
          (o: {
            name = o;
            outputs_connected = [ o ];
            configure_single = o;
            primary = true;
          })
          external ++ [{
            name = "eDP-1";
            outputs_disconnected = external;
            configure_single = "eDP-1";
            primary = true;
          }];
      };
  };
}
