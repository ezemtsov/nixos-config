{ lib, pkgs, config, ... }:

{
  services.xserver.enable = true;

  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages [
        sdk_8_0
        sdk_9_0
        sdk_10_0
      ] + "/share/dotnet";

      EDITOR = "emacsclient";

      NIRI_CONFIG = "/etc/nixos/dotfiles/niri/config.kdl";

      # Setting this to compile rust-openssl
      PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";

      # Use Emacs XIM for input methods
      GTK_IM_MODULE = "xim";
      QT_IM_MODULE = "xim";
    };
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  gtk.iconCache.enable = true;

  # EWM - Emacs Wayland Manager
  programs.ewm = {
    enable = true;
    extraEmacsArgs = ''
      --init-directory /etc/nixos/dotfiles/emacs
    '';
    emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-pgtk;
      config = ./dotfiles/emacs/init.el;
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

  programs.dms-shell = {
    enable = true;
    package = pkgs.dms-shell.overrideAttrs {
      vendorHash = "sha256-cVUJXgzYMRSM0od1xzDVkMTdxHu3OIQX2bQ8AJbGQ1Q=";
      src = pkgs.fetchFromGitHub {
        owner = "AvengeMedia";
        repo = "DankMaterialShell";
        rev = "9723661c80babc97637319d312eeeb2a3e53f8a7";
        hash = "sha256-3/8DjcoLrqWrJR8QyyzvsFOeej4V5JIq4kMYQF0vccs=";
      };
    };
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };

  environment.systemPackages = with pkgs; [
    # EWM Emacs (same package the compositor uses, for dev/debug)
    config.programs.ewm.emacsPackage
    # EXWM packages
    i3status-rust
    flameshot
    xsecurelock
    nemo
  ];

  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "colormix";
    bgclock = "en";
  };

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
        emoji = [ "Noto Color Emoji" ];
      };
    };
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts
      ibm-plex
      font-awesome_6
      noto-fonts-color-emoji
      dejavu_fonts  # Fallback
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
  programs.fish.generateCompletions = false;
  programs.fish.shellInit = ''
    alias k="kubectl"
    alias e="emacsclient"
    set fish_greeting ""
    source (find '${pkgs.emacsPackages.vterm}' -name 'emacs-vterm.fish')
  '';

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.direnv.enableFishIntegration = true;

  users.defaultUserShell = pkgs.fish;

  users.extraUsers.ezemtsov = {
    extraGroups = [
      "wheel"     # for sudo
      "vboxusers" # for virtualbox
      "networkmanager"
      "libvirtd"  # for kvm
      "docker"    # for containers
      "video"     # for brightness ctrl
      "audio"     # for musnix
      "adbusers"  # for android
    ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

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
