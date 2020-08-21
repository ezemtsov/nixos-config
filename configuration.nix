# Edit systhis configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
      ./networking.nix
      ./fonts.nix
      ./desktop.nix
      ./packages.nix
      ./services.nix
      ./musnix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Emacs
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./emacs.nix { inherit pkgs; };
  };

  # Graphics
  hardware.opengl = {
      enable = true;
      driSupport = true;
  };

  location.latitude = 59.91;
  location.longitude = 10.75;
  services.redshift.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Enable power control.
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Enable backlight control.
  programs.light.enable = true;

  # Audio
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  musnix = {
    enable = true;
    kernel = {
      optimize = true;
      realtime = true;
      packages = pkgs.linuxPackages_5_6_rt;
    };
    rtirq = {
      enable = true;
      nameList = "xhci";
      prioHigh = 88;
      prioDecr = 2;
      prioLow = 51;
    };
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Enable docker
  virtualisation = {
    docker.enable = true;
  #   virtualbox.host.enable = true;
  #   virtualbox.host.enableExtensionPack = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";

}
