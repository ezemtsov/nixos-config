{ lib, pkgs, config, ... }:

{
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1";

      EDITOR = "emacsclient";

      NIRI_CONFIG = "/etc/nixos/dotfiles/niri/config.kdl";

      # Setting this to compile rust-openssl
      PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
    };
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.niri.enable = true;
  services.displayManager.gdm.enable = true;

  # Emacs Wayland Manager
  programs.ewm = {
    enable = true;
    extraEmacsArgs = ''
      --init-directory /etc/nixos/emacs
    '';
    emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-pgtk.overrideAttrs (old: {
          # src = /home/ezemtsov/git/emacs;
          # configureFlags = (old.configureFlags or []) ++ [
          #   "--with-skia"
          # ];
          # buildInputs = (old.buildInputs or []) ++ [
          #   pkgs.skia
          #   pkgs.libepoxy
          # ];
          # postPatch = (old.postPatch or "") + ''
          #   mkdir -p src/deps/skia
          # '';
        });
      config = ./emacs/init.el;
      extraEmacsPackages = epkgs: with epkgs; [
        config.programs.ewm.ewmPackage
        treesit-grammars.with-all-grammars
      ] ++ (with epkgs.melpaPackages; [
        vterm
        jinx
        telega
      ]);
    };
  };

  # DMS requires upower to show battery percentage
  services.upower.enable = true;

  # DMS is a nice looking top level shell
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };

  environment.systemPackages = with pkgs; [
    # EWM Emacs (same package the compositor uses, for dev/debug)
    config.programs.ewm.emacsPackage
    xwayland-satellite
    maplestory-cursor

    # EWM packages
    nemo
    bitwarden-cli
    wl-clipboard

    # Niri packages
    rofi
    alacritty
    brightnessctl

    # development
    libxkbcommon
    libGL
    wayland

    # Wayland debugging utilities
    grim
    ffmpeg
    wf-recorder
    wlr-randr      # output configuration
    wayland-utils  # wayland-info
    wev            # wayland event viewer
    slurp          # region selection
    tracy
  ];

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
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        monospace = [ "IBM Plex Mono" ];
        sansSerif = [ "IBM Plex Sans" ];
        serif = [ "IBM Plex Serif" ];
      };
    };
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      ibm-plex
      font-awesome_6
    ];
  };

  gtk.iconCache.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;

  # Define a user account
  programs.fish.enable = true;
  programs.fish.generateCompletions = false;
  programs.fish.shellInit = ''
    alias k="kubectl"
    alias e="emacsclient"
    set fish_greeting ""
    source (find '${pkgs.emacsPackages.vterm}' -name 'emacs-vterm.fish')
    source ${config.programs.ewm.ewmPackage}/etc/emacs-ewm.fish
  '';

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.direnv.enableFishIntegration = true;

  services.udev.extraRules = ''
    # Kinesis keyboard - grant logged-in user access for Clique (WebSerial)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="29ea", TAG+="uaccess", MODE="0666"

    # Enable wake-on-connect for USB-C root hubs (clamshell mode:
    # plugging an external monitor wakes the system from suspend).
    # Matches root hubs under XHCI controllers c5:00.3 and c5:00.4.
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", KERNELS=="0000:c5:00.3", ATTR{power/wakeup}="enabled"
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", KERNELS=="0000:c5:00.4", ATTR{power/wakeup}="enabled"
  '';

  users.defaultUserShell = pkgs.fish;

  users.extraUsers.ezemtsov = {
    extraGroups = [
      "wheel"     # sudo
      "vboxusers" # virtualbox
      "networkmanager"
      "libvirtd"  # kvm
      "docker"    # containers
      "video"     # brightness ctrl
      "audio"     # musnix
      "adbusers"  # android

      # kinesis
      "dialout"
      "uucp"
    ];

    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Finger scanner experiments
  services.fprintd.enable = true;

  age.secrets = {
    claude = {
      file = ./secrets/claude.age;
      path = "/run/secrets/claude";
      owner = "ezemtsov";
      group = "users";
      mode = "600";
    };
  };
}
