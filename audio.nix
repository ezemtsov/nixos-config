{ config, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };

in {
  # Audio
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
  };


  # hardware.pulseaudio = {
  #   enable = true;
  #   package = unstable.pulseaudioFull;
  # };

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
