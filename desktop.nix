{ lib, pkgs, config, ... }:

let
  emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs31-pwayl.overrideAttrs (
      let ewmPath = /home/ezemtsov/git/emacs;
      in lib.mkIf (builtins.pathExists ewmPath) {
        src = builtins.fetchGit {
          url = ewmPath;
          ref = "HEAD";
        };
      });
    config = ./emacs/init.el;
    extraEmacsPackages = epkgs: with epkgs; [
      config.programs.ewm.ewmPackage
      treesit-grammars.with-all-grammars
    ] ++ (with epkgs.melpaPackages; [
      vterm
      jinx
    ]);
    override = final: prev: {
      telega = prev.melpaPackages.telega.overrideAttrs(old: {
        src = builtins.fetchGit {
          url = /home/ezemtsov/git/telega;
          ref = "fractional-slices";
        };
      });
    };
  };

  ferroide = import (builtins.fetchGit {
    url = /home/ezemtsov/git/ferroide;
    ref = "main";
  }) { inherit pkgs; };

  # Master needs Go 1.27, and vendorHash follows its go.sum
  dmsPackage =
    (pkgs.dms-shell.override { buildGoModule = pkgs.buildGo127Module; }).overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "AvengeMedia";
        repo = "DankMaterialShell";
        rev = "bb3e3adaab7b24c79697cb12a27ae76f699a0564";
        fetchSubmodules = true;
        hash = "sha256-Q8O0IseTcC4lO4gAXLRx/JA5vrT3f4G2ON5pXcDt3OU=";
      };
      vendorHash = "sha256-mWKs32BqASlTmA2fazNd83wj53mU6A7WQu/EgJfz3+4=";
    };

in
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
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-user-session --asterisks";
      user = "greeter";
    };
  };

  # Emacs Wayland Manager
  programs.ewm = {
    inherit emacsPackage;
    enable = true;
    extraEmacsArgs = ''
      --init-directory /etc/nixos/emacs
    '';
  };

  # DMS is a nice looking top level shell
  programs.dms-shell = {
    enable = true;
    package = dmsPackage;
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };

  # Manoloide's paintings as the wallpaper; the DMS lock screen reads the dump
  systemd.user.services.ferroide = {
    description = "ferroide wallpaper";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    # A compositor restart drops the connection, retry until the new one listens
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      ExecStart = "${ferroide}/bin/ferroide --every 1h --dump %t/ferroide.bmp";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    # EWM Emacs (same package the compositor uses, for dev/debug)
    config.programs.ewm.emacsPackage
    xwayland-satellite
    adwaita-icon-theme

    # EWM packages
    nemo
    bitwarden-cli
    wl-clipboard
    dtach

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

    emacsPackage
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
      nerd-fonts.symbols-only
      maple-mono.truetype
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

  # Finger scanner and yubikey
  services.fprintd.enable = true;
  services.pcscd.enable = true;

  security.pam.services = {
    polkit-1.fprintAuth = true; # Required for browser prompts
    greetd.fprintAuth = false;
    greetd.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  xdg.mime.defaultApplications."video/mp4" = "mpv.desktop";

  # Cursor theme
  xdg.icons.fallbackCursorThemes = [ "Adwaita" ];
  environment.sessionVariables = {
    # TEMP: remove once the Wayland-Skia display disconnect is diagnosed.
    WL_SKIA_TRACE = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
        cursor-size = lib.gvariant.mkInt32 24;
      };
    }
  ];

  # Collect old nix store generations daily.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  # Trim the Go build cache (lives outside the nix store, has no size limit of its own).
  systemd.tmpfiles.rules = [
    "e /home/ezemtsov/.cache/go-build - - - 1d"
  ];
}
