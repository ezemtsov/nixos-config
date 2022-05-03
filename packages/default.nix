{ pkgs }:

with pkgs;

let
  unstable = import <unstable> { config.allowUnfree = true; };

in rec {
  iconnconfig = libsForQt5.callPackage ./iconnconfig { };

  renoise = unstable.renoise.overrideAttrs(old: {
    src = fetchurl {
      url = "https://files.renoise.com/demo/Renoise_3_3_2_Demo_Linux.tar.gz";
      sha256 = "0d9pnrvs93d4bwbfqxwyr3lg3k6gnzmp81m95gglzwdzczxkw38k";
    };
  });

  x32edit = pkgs.x32edit.overrideAttrs(old: {
    version = "4.3";
    src = fetchurl {
      url = "https://mediadl.musictribe.com/download/software/behringer/X32/X32-Edit_LINUX_4.3.tar.gz";
      sha256 = "0ziqqljd8afvsh0773c4ndymc7vc9sf4b2ks6njl3d4mm9dl2l49";
    };
  });

  # bitwig-studio3 = unstable.bitwig-studio3.overrideAttrs (oldAttrs: rec {
  #   version = "3.3.1";
  #   jre = /home/ezemtsov/Downloads/Bitwig/Linux/patch/bitwig.jar;
  #   src = /home/ezemtsov/Downloads/Bitwig/Linux/bitwig-studio-3.3.1.deb;
  #   postFixup = ''
  #       ${oldAttrs.postFixup}
  #       find -L $out -name "bitwig.jar" -exec cp ${jre} {} \;
  #     '';
  # });
}
