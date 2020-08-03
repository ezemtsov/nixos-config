{ stdenv, config, lib, pkgs, ... }:
{
  environment = {
    variables = {
      MONITOR_PRIMARY = "eDP1";
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "intel" ];

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          wmfocus
          rofi
        ];
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
    };
    picom = {
      enable  = true;
      vSync   = true;    };
  };
}
