{ lib, config, ... }:

{
  options.sources = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config.sources = builtins.mapAttrs (_: fetchTarball) {
      nixos = {
        url = "https://github.com/nixos/nixpkgs/archive/ac1acba43b2f9db073943ff5ed883ce7e8a40a2c.tar.gz";
        sha256 = "sha256:0gl7wxjnsk9fn6ck5dlv629nvs6vj42w49bb27ysxn2xgl0zzy4p";
      };

      unstable = {
        url = "https://github.com/nixos/nixpkgs/archive/c516ad1ee1c9d64d420a14439f50af51aead01bb.tar.gz";
        sha256 = "sha256:12hlalk1zjzdyqlaz3v1ql7qkbymkv9y0gxhjyrnbwqwsbiy26wd";
      };

      emacs-overlay = {
        url = "https://github.com/nix-community/emacs-overlay/archive/8557a967260b6f6fca567dcf6d1dee47aa71871f.tar.gz";
        sha256 = "sha256:1hl1s49whci22mq0v15vwg55yg3ldnbvr2n9i7rkp5fnb9dsyj69";
      };

      home-manager = {
        url = "https://github.com/nix-community/home-manager/archive/07c347bb50994691d7b0095f45ebd8838cf6bc38.tar.gz";
        sha256 = "sha256:0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
      };
  };
}
