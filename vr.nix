{ pkgs, lib, config, ... }:

{
  # TODO: check if that's strictly required
  boot.kernelModules =  [ "v4l2loopback" "evdi" ];

  # Steam
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.package = pkgs.steam.override {
    extraPkgs = (p: with p; [
      gamemode
      mangohud
    ]);
  };

  # Sideloading APK
  programs.adb.enable = true;

  # Extra privileges
  users.users.ezemtsov.extraGroups = [ "adbusers" "gamemode" ];

  # Service discovery for WiVRN
  services.avahi.enable = true;
  services.avahi.publish = {
    enable = true;
    userServices = true;
  };

  # Remote desktop
  programs.immersed.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback evdi ];

  environment.systemPackages = with pkgs; [
    wlx-overlay-s
    virtualgl
    lshw
    pciutils
    usbutils
    rocmPackages.rocm-smi
  ];

  programs.alvr.enable = true;
  programs.alvr.openFirewall.enable = true;

  # VR encoder and remote service
  services.wivrn = {
    enable = true;
    autoStart = true;
    defaultRuntime = true;
    openFirewall = true;
    package = pkgs.wivrn.override rec {
      # Enable VAAPI support
      ffmpeg = pkgs.ffmpeg-full;

      # Half-Life: Alyx controller fix
      ovrCompatSearchPaths = "${opencomposite}/lib/opencomposite";
      opencomposite = pkgs.opencomposite.overrideAttrs {
        src = pkgs.fetchFromGitLab {
          fetchSubmodules = true;
          owner = "OrionMoonclaw";
          repo = "OpenOVR";
          rev = "81d4363a6533276d4726f2191d7a30835faf60d1";
          hash = "sha256:1q39404vqqiklbbwrqwnwisihfwaa5j0g7xxi8yp7ikh3b4prpad";
        };
      };
    };
  };

  # CoreCtrl
  programs.corectrl.enable = true;

  # Thunderbolt (eGPU)
  services.hardware.bolt.enable = true;

  # VA-API encoding drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ ];
  };

  services.open-webui.enable = false;

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    loadModels = [ "mistral:latest" "devstral:latest" ];
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      OLLAMA_LLM_LIBRARY = "rocm_v60000";
    };
  };
}
