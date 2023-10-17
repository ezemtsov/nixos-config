{ config, lib, pkgs, ... }:

{
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages ([
        sdk_6_0
        sdk_7_0
      ]);
      EDITOR = "emacsclient";
    };
  };

  # Graphics
  hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
  };

  services = {
    picom = {
      enable = true;
      vSync = true;
      backend = "egl";
    };
    xserver = {
      enable = true;
      windowManager = {
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          extraPackages = with pkgs; [
            wmfocus
            xclip
          ];
        };
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
