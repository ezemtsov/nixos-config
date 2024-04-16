{ config, lib, pkgs, ... }:

{
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP-1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      DOTNET_ROOT = with pkgs.dotnetCorePackages; combinePackages ([
        sdk_6_0
        sdk_7_0
        sdk_8_0
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

  services.picom = {
    enable = true;
    vSync = true;
    backend = "egl";
  };

  services.autorandr = {
    enable = true;
    profiles =
      let
        eDP-1 =
          "00ffffffffffff0006afed2600000000" +
          "001c0104a522137802c635a356529e28" +
          "0a505400000001010101010101010101" +
          "010101010101143780b4703826406c30" +
          "aa0058c21000001a102c80b470382640" +
          "6c30aa0058c21000001a000000fe0047" +
          "4857314b804231353648414e00000000" +
          "000341029e001000000a010a20200002";
        DP-1-1-8 =
          "00ffffffffffff0010ac9c4157594c41" +
          "221d0104a53c22783eee95a3544c9926" +
          "0f5054a54b00714f8180a940d1c00101" +
          "010101010101565e00a0a0a029503020" +
          "350055502100001a000000ff0036595a" +
          "485153320a2020202020000000fc0044" +
          "454c4c20553237313944430a000000fd" +
          "00384c1e5a19010a20202020202001d2" +
          "02031cf14f9005040302071601061112" +
          "1513141f23097f0783010000023a8018" +
          "71382d40582c450055502100001e7e39" +
          "00a080381f4030203a0055502100001a" +
          "011d007251d01e206e28550055502100" +
          "001ebf1600a08038134030203a005550" +
          "2100001a000000000000000000000000" +
          "00000000000000000000000000000012";
        DP-3 =
          "00ffffffffffff0010aceb404c393130" +
          "181c0103803c22782aee95a3544c9926" +
          "0f5054a54b00714fa9408180d1c00101" +
          "010101010101565e00a0a0a029503020" +
          "350055502100001a000000ff004a3058" +
          "594e3836453031394c0a000000fc0044" +
          "454c4c205532373137440a20000000fd" +
          "00324b1e5819000a20202020202001e4" +
          "020324f14f9005040302071601061112" +
          "1513141f23091f078301000067030c00" +
          "10000032023a801871382d40582c4500" +
          "55502100001e7e3900a080381f403020" +
          "3a0055502100001a011d007251d01e20" +
          "6e28550055502100001ebf1600a08038" +
          "134030203a0055502100001a00000000" +
          "000000000000000000000000000000b2";
      in
        {
          "default" = {
            fingerprint = { inherit eDP-1; };
            config.eDP-1 = {
              enable = true;
              primary = true;
              mode = "1920x1080";
            };
          };
          "usb-c" = {
            fingerprint = { inherit eDP-1 DP-1-1-8; };
            config.eDP-1.enable = false;
            config.DP-1-1-8 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
            };
          };
          "hdmi" = {
            fingerprint = { inherit eDP-1 DP-3; };
            config.eDP-1.enable = false;
            config.DP-3 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
            };
          };
        };
  };

  services.xserver.enable = true;

  # Give EXWM permission to control the session.
  services.xserver.displayManager = {
    sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
  };

  services.xserver.windowManager = {
    session = lib.singleton {
      name = "exwm";
      start = ''
        ${config.services.emacs.package}/bin/emacs \
            --debug-init
      '';
    };
  };

  # Keyboard options
  services.xserver.xkb.layout = "us,ru,no";
  services.xserver.xkb.options = "grp:caps_toggle";
  services.xserver.libinput = {
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
      font-awesome_5
      dejavu_fonts
      nerdfonts
      source-code-pro
    ];
  };
}
