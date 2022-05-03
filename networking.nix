{ config, pkgs, ... }:

{
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 8100 40051 5000 ];
    };
    hostName = "ezemtsov";
    networkmanager = {
      enable = true;
    };
    extraHosts =
      ''
        100.108.86.109 review.resoptima.net
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

  fileSystems."/mnt/data" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/external" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/external";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/k8s" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/k8test";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/irma_data" = {
    device = "jackson.resoptima.local:/mnt/ssdstorage/irma_data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/internal.resoptima.net" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/internal.resoptima.net";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

}
