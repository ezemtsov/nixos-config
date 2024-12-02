{ config, pkgs, lib, ... }:


let
  sources = import npins/default.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./networking.nix
      ./desktop.nix
      ./home.nix
      ./packages.nix
      "${sources.home-manager}/nixos/default.nix"
#      ./test.nix
    ];

  documentation.enable = false;

  # Configure the Nix package manager
  nixpkgs = {
    overlays = [
      (import sources.emacs-overlay)
    ];
    pkgs = import sources.nixpkgs {
      config.allowUnfree = true;
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

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;

    # Enable KVM for OSX virtualization
    extraModprobeConfig = ''
        options kvm_intel nested=1
        options kvm_intel emulate_invalid_guest_state=0
        options kvm ignore_msrs=1
      '';

    # This is required for dotnet to run correctly
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;

    supportedFilesystems = [ "exfat" ];
  };

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Enable power saving
  powerManagement.enable = true;

  # Emacs
  services.emacs = {
    enable = true;
    install = true;
    package = import ./emacs.nix { inherit pkgs; };
  };

  location.latitude = 59.91;
  location.longitude = 10.75;
  #services.redshift.enable = true;

  # Set your time zone.
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
  virtualisation = {
    docker.enable = true;
    # virtualbox.host.enable = true;
    # this is needed to get a bridge with DHCP enabled
    libvirtd.enable = true;
  };

  # Enable USB automount
  services.gvfs.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
  };

  hardware.pulseaudio.enable = lib.mkForce false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05";
}
