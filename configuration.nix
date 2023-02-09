# Edit systhis configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

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
    settings = {
      trusted-users = [ "ezemtsov" ];
      max-jobs = lib.mkDefault 8;
    };
    extraOptions = ''
      netrc-file = /etc/nix/netrc
    '';
  };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    cleanTmpDir = true;

    # Enable KVM for OSX virtualization
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    # This is required for dotnet to run correctly
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;
  };

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Emacs
  services.emacs = {
    enable = true;
    install = true;
    package = import ./emacs.nix { inherit pkgs; };
  };

  location.latitude = 59.91;
  location.longitude = 10.75;
  services.redshift.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Enable power control.
  services.tlp.enable = true;
  # powerManagement.powertop.enable = true;

  # Enable backlight control.
  programs.light.enable = true;

  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable docker
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
    # virtualbox.host.enableExtensionPack = true;
    # this is needed to get a bridge with DHCP enabled
    libvirtd.enable = true;
  };

  # Enable USB automount
  services.gvfs.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11";

}
