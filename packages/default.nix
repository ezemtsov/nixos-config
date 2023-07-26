{ pkgs ? import <nixos> {} }:

with pkgs;

let
  unstable = import <unstable> { config.allowUnfree = true; };

in
rec {
  fsautocomplete =
    let
      dotnet = pkgs.dotnetCorePackages.sdk_7_0;

      fsautocomplete-dll = pkgs.stdenvNoCC.mkDerivation {
        name = "fsautocomplete-dll";
        src = pkgs.fetchurl {
          url = "https://github.com/fsharp/FsAutoComplete/releases/download/v0.59.2/fsautocomplete.0.59.2.nupkg";
          sha256 = "007nviwf1zn9v4575nr1pk7s0qpkrz34hai4blfzskbnl8mp16y0";
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
        dotnet ${fsautocomplete-dll}/share/tools/net7.0/any/fsautocomplete.dll "$@"
      '';
    };

}
