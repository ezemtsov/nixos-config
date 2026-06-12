{ lib
, stdenv
, dpkg
, autoPatchelfHook
, zlib
, openssl
, libnl
, ...
}:

let
  debFiles =
    lib.filter
      (name: builtins.match "falcon-sensor_.*_amd64\\.deb" name != null)
      (builtins.attrNames (builtins.readDir ./.));

  debFile =
    if debFiles == [ ] then
      throw "Put falcon-sensor_<version>_amd64.deb in /etc/nixos/crowdstrike"
    else if builtins.length debFiles > 1 then
      throw "Expected one falcon-sensor_<version>_amd64.deb in /etc/nixos/crowdstrike, found: ${lib.concatStringsSep ", " debFiles}"
    else
      builtins.head debFiles;

  versionMatch = builtins.match "falcon-sensor_(.*)_amd64\\.deb" debFile;
in
stdenv.mkDerivation {
  pname = "falcon-sensor-unwrapped";
  version = builtins.head versionMatch;
  src = ./. + "/${debFile}";

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  # falcon-sensor dlopens libssl by SONAME, so autoPatchelf cannot infer it from DT_NEEDED.
  runtimeDependencies = [
    (lib.getLib openssl)
    (lib.getLib libnl)
  ];

  buildInputs = [
    libnl
    openssl
    zlib
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    substituteInPlace lib/systemd/system/falcon-sensor.service \
      --replace-fail "/var/run/falcond.pid" "/run/falcond.pid"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    cp -r . "$out"
    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = "falconctl";
    description = "CrowdStrike Falcon Sensor";
    homepage = "https://www.crowdstrike.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
