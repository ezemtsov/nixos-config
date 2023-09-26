{ lib, config, ... }:

{
  options.sources = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config.sources = builtins.mapAttrs (_: fetchTarball) {
      nixos = {
        url = "https://github.com/nixos/nixpkgs/archive/66aedfd010204949cb225cf749be08cb13ce1813.tar.gz";
        sha256 = "sha256:1jspq3g1wzdfgmnp4wzzrwh2cfn9q2w86b25bgwr7ygdcdap3fqd";
      };

      emacs-overlay = {
        url = "https://github.com/nix-community/emacs-overlay/archive/4ba15d6f4310459e6da08dcd4d3df7f4d102bdf0.tar.gz";
        sha256 = "sha256:1c5d78aypds7pg02qh8n4fgarasq3m6nxap4ibr7cnfp0yarmxhc";
      };

      home-manager = {
        url = "https://github.com/nix-community/home-manager/archive/ba2c0737cc848db03470828fdb5e86df75ed42a8.tar.gz";
        sha256 = "sha256:060nxjz7zgjxdmq0jmwmq07lyncr3mmlckhk74d6li04fhab126r";
      };
  };
}
