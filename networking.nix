{ config, pkgs, ... }:

{
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 8100 ];
    };
    hostName = "ezemtsov";
    networkmanager = {
      enable = true;
      packages = with pkgs; [ networkmanagerapplet ];
    };
  };
  hardware.bluetooth.enable = true;
  programs.nm-applet.enable = true;
}
