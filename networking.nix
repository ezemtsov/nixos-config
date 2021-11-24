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
        127.0.0.1 postgresql
        127.0.0.1 redis
        127.0.0.1 enopt-eclipse-parser-api
        10.147.18.203 akerbp.resoptima.net a21-p1-app151 argocd-akerbp.resoptima.net
        51.13.98.122 irma-neptune-1.resoptima.net
      '';
  };

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
