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
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Graphics
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable power control.
  powerManagement.enable = true;

  # Enable backlight control.
  programs.light.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Sounds
  hardware.pulseaudio.enable = true;
  sound.enable = true;
  
  # Emacs
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./emacs.nix { inherit pkgs; };
  };
  
  # Enable docker
  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03";

}
