{ ... }:

{
  networking = {
    enableIPv6 = true;
    # Tailscale's fd7a::/48 ULA is scope-global, so getaddrinfo hands out AAAA
    # records despite there being no public IPv6 route; prefer IPv4 to avoid the
    # connect-timeout fallback (default table with ::ffff:0:0/96 raised 10->100).
    getaddrinfo.precedence = {
      "::1/128" = 50;
      "::/0" = 40;
      "2002::/16" = 30;
      "::/96" = 20;
      "::ffff:0:0/96" = 100;
    };
    firewall = {
      enable = true;
      allowPing = true;
      # allowedTCPPorts = [ 42000 8000 ];
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

  # search engine
  services.jackett.enable = true;
}
