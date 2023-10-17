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
  programs.nm-applet.enable = true;
  programs.wireshark.enable = true;

  fileSystems."/mnt/internal" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/internal";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/external" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/external";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

}
