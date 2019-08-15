{ config, pkgs, ... }:

let
    slim-theme = pkgs.fetchFromGitHub {
      owner = "ezemtsov";
      repo = "slim-theme";
      rev = "aa29ec80b550c709e3c5be14066e9c25948adf38";
      sha256 = "13xx75fcaqvwi5r3cb1cr928wh79h95cx606xmrmsvjb3bqjwwd2";
   };
   
in
{

  environment = {
    etc = {
      "X11/Xresources"            .source = ./dotfiles/Xresources.conf;
    };
    variables.MONITOR_PRIMARY = "eDP1";
    variables.MONITOR_EXTERNAL = "HDMI2";
  };


  services = {
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
      };
      windowManager = {
        i3 = {
          enable     = true;
          package = pkgs.i3-gaps;
          extraPackages = with pkgs; [
            i3lock-color
            i3-easyfocus
            rofi
            compton
            ];
            
         extraSessionCommands = ''
           ${pkgs.xlibs.xrdb}/bin/xrdb -load /etc/X11/Xresources
         '';
        };
        default = "i3";
      };
      displayManager.slim = {
        enable      = true;
        autoLogin   = true;
        theme       = slim-theme;
        defaultUser = "ezemtsov";
      };
      videoDrivers = [ "intel" ];      
      dpi = 125;

      # Keyboard options
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle";
      libinput = {
        enable           = true;	# touchpad
        naturalScrolling = true;
        accelSpeed       = "0.3";
        tapping          = false;
      };
    };
    compton = {
      enable = true;
      backend = "xrender";
      vSync = "opengl";
    };
  };
}
