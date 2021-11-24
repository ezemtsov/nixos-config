{ config, pkgs, ... }:

{
  # Audio
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  security.rtkit.enable = true;

  # musnix = {
  #   enable = true;
  #   kernel = {
  #     optimize = true;
  #     realtime = true;
  #   };
  #   rtirq = {
  #     enable = true;
  #     nameList = "xhci";
  #     prioHigh = 85;
  #     prioDecr = 2;
  #     prioLow = 51;
  #   };
  # };
}
