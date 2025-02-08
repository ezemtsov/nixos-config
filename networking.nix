{ config, pkgs, ... }:

{
  networking = {
    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 42000 ];
      checkReversePath = "loose";
    };
    hostName = "ezemtsov";
    networkmanager.enable = true;
    extraHosts = ''
    '';
  };

  # enable the tailscale service
  services.tailscale.enable = true;
  programs.fuse.userAllowOther = true;
}
