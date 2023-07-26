{ lib, config, ... }:

{
  options.sources = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config.sources = builtins.mapAttrs (_: fetchTarball) {
      nixos = {
        url = "https://github.com/nixos/nixpkgs/archive/b12803b6d90e2e583429bb79b859ca53c348b39a.tar.gz";
        sha256 = "sha256:1l9sa8hd242xrb2j18mj4f62f3cw0bf5pafp58gdl0jkl61dpapr";
      };

      unstable = {
        url = "https://github.com/nixos/nixpkgs/archive/c516ad1ee1c9d64d420a14439f50af51aead01bb.tar.gz";
        sha256 = "sha256:12hlalk1zjzdyqlaz3v1ql7qkbymkv9y0gxhjyrnbwqwsbiy26wd";
      };

      emacs-overlay = {
        url = "https://github.com/nix-community/emacs-overlay/archive/22c986c6ed401dcdbc5fdbfe7e0cf551a35b58dc.tar.gz";
        sha256 = "sha256:1hl1s49whci22mq0v15vwg55yg3ldnbvr2n9i7rkp5fnb9dsyj69";
      };

      home-manager = {
        url = "https://github.com/nix-community/home-manager/archive/ba2c0737cc848db03470828fdb5e86df75ed42a8.tar.gz";
        sha256 = "sha256:060nxjz7zgjxdmq0jmwmq07lyncr3mmlckhk74d6li04fhab126r";
      };
  };
}
