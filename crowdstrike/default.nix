{ lib
, buildFHSEnv
, symlinkJoin
, callPackage
, falcon-sensor-unwrapped ? callPackage ./falcon-sensor-unwrapped.nix { }
, ...
}:

let
  sensorBuild = lib.last (lib.splitString "-" falcon-sensor-unwrapped.version);
  crowdStrikePath = "${falcon-sensor-unwrapped}/opt/CrowdStrike";

  optDirectories = [
    "/opt/CrowdStrike"
    "/opt/CrowdStrike/ASPM"
    "/opt/CrowdStrike/ASPM/bin"
    "/opt/CrowdStrike/ASPM/results"
    "/opt/CrowdStrike/ASPM/tmp"
    "/opt/CrowdStrike/Falcon4IT"
    "/opt/CrowdStrike/Falcon4IT/bin"
    "/opt/CrowdStrike/Falcon4IT/results"
    "/opt/CrowdStrike/Packages"
  ];

  optPayloadFiles = [
    "KernelModuleArchive${sensorBuild}"
    "README"
    "falcon-flow${sensorBuild}"
    "falcon-fxpredict${sensorBuild}"
    "falcon-kernel-check${sensorBuild}"
    "falcon-nva-scanner${sensorBuild}"
    "falcon-sensor-bpf${sensorBuild}"
    "falcon-sensor${sensorBuild}"
    "falcon-zip-inspect${sensorBuild}"
    "falconctl${sensorBuild}"
    "falcond${sensorBuild}"
    "libelf-sourceware.so.1-${sensorBuild}"
    "libfalconfxp.so.3-${sensorBuild}"
  ];

  optPayloadLinks = {
    KernelModuleArchive = "KernelModuleArchive${sensorBuild}";
    falcon-flow = "falcon-flow${sensorBuild}";
    falcon-fx = "falcon-fxpredict${sensorBuild}";
    falcon-fxpredict = "falcon-fxpredict${sensorBuild}";
    falcon-kernel-check = "falcon-kernel-check${sensorBuild}";
    falcon-nva-scanner = "falcon-nva-scanner${sensorBuild}";
    falcon-predict = "falcon-fxpredict${sensorBuild}";
    falcon-sensor = "falcon-sensor${sensorBuild}";
    falcon-sensor-bpf = "falcon-sensor-bpf${sensorBuild}";
    falcon-zip-inspect = "falcon-zip-inspect${sensorBuild}";
    falconctl = "falconctl${sensorBuild}";
    falcond = "falcond${sensorBuild}";
    "libelf-sourceware.so.1" = "libelf-sourceware.so.1-${sensorBuild}";
    "libfalconfxp.so.3" = "libfalconfxp.so.3-${sensorBuild}";
  };

  tmpfilesRules =
    [
      "r /opt/CrowdStrike - - - -"
      "d /opt 0755 root root -"
    ]
    ++ map (dir: "d ${dir} 0750 root root -") optDirectories
    ++ map (file: "L+ /opt/CrowdStrike/${file} - - - - ${crowdStrikePath}/${file}") optPayloadFiles
    ++ lib.mapAttrsToList (link: target: "L+ /opt/CrowdStrike/${link} - - - - /opt/CrowdStrike/${target}") optPayloadLinks;

  falconFHSWrapper = mainProgram:
    buildFHSEnv {
      inherit (falcon-sensor-unwrapped) version;
      name = mainProgram;
      chdirToPwd = false;
      targetPkgs = pkgs: with pkgs; [
        libnl
        openssl
        zlib
      ];
      runScript = "${falcon-sensor-unwrapped}/opt/CrowdStrike/${mainProgram}";
    };

  falconctl = falconFHSWrapper "falconctl";
  falcond = falconFHSWrapper "falcond";
  falcon-kernel-check = falconFHSWrapper "falcon-kernel-check";
in
symlinkJoin {
  pname = "falcon-sensor";
  inherit (falcon-sensor-unwrapped) version;

  paths = [
    falconctl
    falcond
    falcon-kernel-check
  ];

  passthru = {
    inherit tmpfilesRules;
    unwrapped = falcon-sensor-unwrapped;
  };

  meta = falcon-sensor-unwrapped.meta // {
    description = "FHS-wrapped CrowdStrike Falcon Sensor tools";
    mainProgram = "falconctl";
    platforms = [ "x86_64-linux" ];
  };
}
