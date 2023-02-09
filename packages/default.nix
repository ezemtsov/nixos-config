{ pkgs ? import <nixos> {} }:

with pkgs;

let
  unstable = import <unstable> { config.allowUnfree = true; };

in
rec {
  iconnconfig = libsForQt5.callPackage ./iconnconfig { };

  renoise = unstable.renoise.overrideAttrs (old: {
    src = fetchurl {
      url = "https://files.renoise.com/demo/Renoise_3_3_2_Demo_Linux.tar.gz";
      sha256 = "0d9pnrvs93d4bwbfqxwyr3lg3k6gnzmp81m95gglzwdzczxkw38k";
    };
  });

  x32edit = pkgs.x32edit.overrideAttrs (old: {
    version = "4.3";
    src = fetchurl {
      url = "https://mediadl.musictribe.com/download/software/behringer/X32/X32-Edit_LINUX_4.3.tar.gz";
      sha256 = "0ziqqljd8afvsh0773c4ndymc7vc9sf4b2ks6njl3d4mm9dl2l49";
    };
  });

  fsautocomplete =
    let
      dotnet = pkgs.dotnetCorePackages.sdk_6_0;

      fsautocomplete-dll = pkgs.stdenvNoCC.mkDerivation {
        name = "fsautocomplete-dll";
        src = pkgs.fetchurl {
          url = "https://github.com/fsharp/FsAutoComplete/releases/download/v0.58.2/fsautocomplete.0.58.2.nupkg";
          sha256 = "1346f62xzra0rdi248xkny6bpablm4f0van0vspn6f5fm3m87x1f";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        dontUnpack = true;
        dontBuild = true;
        dontFixup = true;

        installPhase = ''
          mkdir -p $out/bin $out/share
          unzip $src -d $out/share
          echo $out/share/tools
        '';
      };
    in
    pkgs.writeShellApplication {
      name = "fsautocomplete";
      runtimeInputs = [
        dotnet
        fsautocomplete-dll
      ];
      text = ''
        export DOTNET_ROOT=${dotnet}
        unset DOTNET_SYSTEM_GLOBALIZATION_INVARIANT
        dotnet ${fsautocomplete-dll}/share/tools/net6.0/any/fsautocomplete.dll "$@"
      '';
    };

}
