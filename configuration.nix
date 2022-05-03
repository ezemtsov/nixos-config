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
      ./desktop.nix
      ./packages.nix
      ./services.nix
      ./audio.nix
      ./cachix.nix
    ];

  nix = {
    package = pkgs.nix_2_3;
    trustedUsers = [ "ezemtsov" ];
    extraOptions = ''
      netrc-file = /etc/nixos/netrc
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  # This is required for dotnet to run correctly
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 524288;

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Emacs
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./emacs.nix { inherit pkgs; };
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

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Enable docker
  virtualisation = {
    docker.enable = true;
      virtualbox.host.enable = true;
      # virtualbox.host.enableExtensionPack = true;
  };


  # Enable USB automount
  services.gvfs.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09";

}
