{ config, lib, pkgs, ... }:

with lib;
let
  slim-theme = pkgs.fetchFromGitHub {
    owner = "ezemtsov";
    repo = "slim-theme";
    rev = "aa29ec80b550c709e3c5be14066e9c25948adf38";
    sha256 = "13xx75fcaqvwi5r3cb1cr928wh79h95cx606xmrmsvjb3bqjwwd2";
  };
in {
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP1";
      MONITOR_EXTERNAL = "HDMI2";
      XMODIFIERS="@im=exwm-xim";
      GTK_IM_MODULE="xim";
      QT_IM_MODULE="xim";
      CLUTTER_IM_MODULE="xim";
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "intel" ];

      displayManager = {
        # Give EXWM permission to control the session
        sessionCommands =
          "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
        # Enable default user for login
        slim = {
          enable      = true;
          autoLogin   = false;
          theme       = slim-theme;
          defaultUser = "ezemtsov";
        };
      };
      # Configure desktop environment:
      windowManager.session = singleton {
        name = "exwm";
        start = ''
          ${pkgs.emacsGit}/bin/emacs -- eval '(progn (server-start) (exwm-enable))'
        '';
      };

      # Keyboard options
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle";
      libinput = {
        enable           = true;
        naturalScrolling = true;
        accelSpeed       = "0.3";
        tapping          = false;
      };
      dpi = 125;
    };
    compton = {
      enable = true;
      backend = "xrender";
      vSync = true;
    };
  };
}
