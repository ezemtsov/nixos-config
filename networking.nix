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
      packages = with pkgs; [ ];#networkmanagerapplet ];
    };
    extraHosts =
      ''
        192.168.167.51 internal.resoptima.net
        172.16.1.3 akerbp.resoptima.net a21-p1-app151 argocd-akerbp.resoptima.net
      '';
  };
  hardware.bluetooth.enable = true;
  programs.nm-applet.enable = true;

  fileSystems."/jackson/internal" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/internal";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/jackson/data" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/jackson/external" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/external";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/jackson/k8s" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/k8test";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/jackson/irma_data" = {
    device = "jackson.resoptima.local:/mnt/ssdstorage/irma_data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/jackson/internal.resoptima.net" = {
    device = "jackson.resoptima.local:/mnt/bigstorage/internal.resoptima.net";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

}
