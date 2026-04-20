{ ... }:

{
  networking = {
    enableIPv6 = false; # TODO: Figure out why ip6 is so slow
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
