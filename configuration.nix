{ config, pkgs, lib, sources, ... }:

let
  sources = import npins/default.nix;
in {
  _module.args = { inherit sources; };

  imports =
    [
      ./hardware-configuration.nix
      ./networking.nix
      ./desktop.nix
      ./packages.nix
      "${sources.home-manager}/nixos"
      "${sources.agenix}/modules/age.nix"
      "${sources.musnix}"
      ./test.nix
    ];

  system.rebuild.enableNg = false;

  # Fish is fucked up and slows down the system build
  documentation.enable = false;
  documentation.man.generateCaches = false;

  # Configure the Nix package manager
  nixpkgs = {
    overlays = [
      (import sources.emacs-overlay)
    ];
    pkgs = import sources.nixpkgs {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "dotnet-core-combined"
        "dotnet-wrapped-combined"
        "dotnet-combined"
      ];
    };
  };

  nix = {
    package = pkgs.nix_2_3;
    nixPath = ["nixpkgs=${sources.nixpkgs}:nixos-config=/etc/nixos/configuration.nix"];
    settings = {
      trusted-users = [ "ezemtsov" ];
      max-jobs = "auto";
      netrc-file = "/etc/nix/netrc";
    };
  };

  # Replace command-not-found with nix-index
  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;
  programs.command-not-found.enable = false;
  services.locate.enable = true;

  boot = {
    # Pick latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Make booting nicer
    plymouth.enable = true;

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;

    # This is required for dotnet to run correctly
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;

    supportedFilesystems = [ "exfat" ];
  };

  # Enable power saving
  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      CPU_SCALING_GOVERNOR_ON_AC="performance";
    };
  };

  # Emacs
  services.emacs = {
    enable = false;
    install = true;
    package = import ./emacs.nix { inherit pkgs; };
  };

  # Set location and time zone
  location.latitude = 59.91;
  location.longitude = 10.75;
  time.timeZone = "Europe/Oslo";

  # Enable backlight control.
  programs.light.enable = true;

  # Security
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable docker
  virtualisation.docker.enable = true;

  # KVM (for nix vmTools)
  boot.kernelModules =  [ "kvm-amd" ];
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu.ovmf = {
  #     enable = true;
  #     packages = [ (pkgs.OVMF.override {
  #       secureBoot = true;
  #       tpmSupport = true;
  #     }).fd];
  #   };
  #   qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  # };

  # Enable USB automount
  services.gvfs.enable = true;

  # Audio
  musnix.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # jack.enable = true;
    pulse.enable = true;
    # socketActivation = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.11";
}
