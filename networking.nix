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
        192.168.167.51 internal.resoptima.net
        172.16.1.2 akerbp.resoptima.net a21-p1-app151 argocd-akerbp.resoptima.net
        192.168.167.54 spirit-energy-internal-1.resoptima.net
        127.0.0.1 argocd-test-1.resoptima.net
        127.0.0.1 reg-test-1.resoptima.net
        127.0.0.1 azu-test-1.resoptima.net
        51.13.88.74 eze-azure-3.resoptima.net
      '';
  };
  hardware.bluetooth.enable = false;
  programs.nm-applet.enable = true;

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
