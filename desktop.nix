{ config, lib, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
  myemacs = import ./emacs.nix { inherit pkgs; };

in {
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = "$(dirname $(realpath $(which dotnet)))";
    };
  };

  # Graphics
  hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
  };

  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true; # so that gtk works properly
  #   extraPackages = with pkgs; [
  #     xwayland
  #     swaylock
  #     swayidle
  #     wl-clipboard
  #     mako # notification daemon
  #     unstable.alacritty # Alacritty is the default terminal in the config
  #     rofi
  #     unstable.wmfocus
  #     unstable.waybar
  #   ];
  #   extraSessionCommands = ''
  #     export _JAVA_AWT_WM_NONREPARENTING=1
  #     export EDITOR=emacs
  #   '';
  # };

  services = {
    picom = {
      enable = true;
      vSync = true;
      backend = "glx";
    };
    xserver = {
      enable = true;
      windowManager = {
        # i3 = {
        #   enable = true;
        #   package = pkgs.i3-gaps;
        #   extraPackages = with pkgs; [
        #     wmfocus
        #     rofi
        #     xclip
        #     i3lock
        #     unstable.i3status-rust
        #     unstable.alacritty
        #   ];
        # };
        session = lib.singleton {
          name = "exwm";
          start = "${myemacs}/bin/emacs --eval '(progn (server-start) (exwm-enable))'";
        };
      };

      displayManager = {
        # Give EXWM permission to control the session.
        sessionCommands = ''
            ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER
        '';
      };

      # Keyboard options
      layout = "us,ru,no";
      xkbOptions = "grp:caps_toggle";
      libinput = {
        enable = true;
        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelSpeed = "0.3";
        };
      };
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
    };
    fontDir.enable = true;
    fonts = with pkgs; [
      corefonts
      jetbrains-mono
      font-awesome_5
      dejavu_fonts
      source-code-pro
    ];
  };
}
