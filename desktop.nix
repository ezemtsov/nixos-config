{ config, lib, pkgs, ... }:

{
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages ([
        sdk_7_0
        sdk_8_0
      ]);
      EDITOR = "emacsclient";

      # Setting this to compile rust-openssl
      PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
    };
  };

  # Copy paste between X windows
  services.clipcat.enable = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.picom = {
    enable = true;
    vSync = true;
    backend = "egl";
    settings.unredir-if-possible-exclude = [
      "name *= 'Chromium'"
    ];
  };

  services.xserver.enable = true;

  # Give EXWM permission to control the session.
  services.xserver.displayManager = {
    sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
  };

  services.xserver.windowManager = {
    session = lib.singleton {
      name = "exwm";
      start = "/run/current-system/sw/bin/emacs";
    };
  };

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
      dejavu_fonts
      source-code-pro
      iosevka-comfy.comfy
    ];
  };
}
