{ lib, pkgs, ... }:

{
  services.xserver.enable = true;

  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages [
        sdk_8_0
        sdk_9_0
      ] + "/share/dotnet";

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

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    # EXWM packages
    i3status-rust
    flameshot
    grobi
    xclip
    xsecurelock
    nemo
  ];

  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "colormix";
    bgclock = "en";
  };

  # Configure EXWM
  services.xserver = {
    # Give EXWM permission to control the session.
    displayManager.sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
    windowManager = {
      session = lib.singleton {
        name = "exwm";
        start = ''
          /run/current-system/sw/bin/emacs \
          --init-directory /etc/nixos/dotfiles/emacs \
          --eval "(server-start)"
        '';
      };
    };
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

  # Set the environment variable
  # Instead, use EnvironmentFile for your user session
  environment.extraInit = ''
    export ANTHROPIC_API_KEY="$(cat ${config.age.secrets.claude.path})"
  '';
  age.secrets = {
    claude = {
      file = ./secrets/claude.age;
      path = "/run/secrets/claude";
      owner = "ezemtsov";
      group = "users";
      mode = "600";
    };
  };

  # Setup home-manager to reuse global channel
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.backupFileExtension = "backup";

  home-manager.users.ezemtsov = { ... }: {
    home.stateVersion = "25.05";
    home.enableNixpkgsReleaseCheck = false;

    services.dunst.enable = true;
  };
}
