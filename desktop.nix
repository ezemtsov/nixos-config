{ lib, pkgs, config, ... }:

let
  skiaEmacsBase = pkgs.emacs-git.override {
    withX = false;
    withCairo = false;
    withGTK3 = false;
    withPgtk = false;
    withXwidgets = false;
    withToolkitScrollBars = false;
  };

  skiaEmacs = skiaEmacsBase.overrideAttrs (old: {
    src = /home/ezemtsov/git/emacs;
    configureFlags = (lib.filter
      (flag:
        !(lib.elem flag [
          "--without-gif"
          "--without-jpeg"
          "--without-png"
          "--without-tiff"
        ]))
      (old.configureFlags or [])) ++ [
      "--with-rsvg"
      "--with-pwayl"
      "--with-skia"
      "--with-gif"
      "--with-jpeg"
      "--with-png"
      "--with-tiff"
    ];
    buildInputs = old.buildInputs ++ (with pkgs; [
      fontconfig
      freetype
      giflib
      libjpeg
      libpng
      libtiff
      librsvg
      skia
      libepoxy
      wayland
      wayland-protocols
      libxkbcommon
    ]);
    nativeBuildInputs = old.nativeBuildInputs ++ (with pkgs; [
      autoconf
      automake
      wayland-scanner
    ]);
    preConfigure = (old.preConfigure or "") + ''
      ./autogen.sh
    '';
  });

  emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
    package = skiaEmacs;
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
        src = pkgs.fetchFromGitHub {
          owner = "zevlg";
          repo = "telega.el";
          rev = "6c82622dbd98ac8ea024f56490607151d9bd1032";
          hash = "sha256-WE4WhuJHQdPGWHrZDqxgdktHgJgBt0iUBAplQi3fX7w=";
        };
      });
    };
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
    adwaita-icon-theme

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

  # Finger scanner and yubikey
  services.fprintd.enable = true;
  services.pcscd.enable = true;

  security.pam.services = {
    polkit-1.fprintAuth = true; # Required for browser prompts
    greetd.fprintAuth = true;
    greetd.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

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
}
