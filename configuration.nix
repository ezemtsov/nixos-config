{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./sources.nix
      ./networking.nix
      ./desktop.nix
      ./home.nix
      ./packages.nix
      ./services.nix
      ./cachix.nix
    ];

  documentation.enable = false;

  # Configure the Nix package manager
  nixpkgs = {
    pkgs = import config.sources.nixos { config.allowUnfree = true; };
    overlays = [ (import config.sources.emacs-overlay) ];
  };

  nix = {
    package = pkgs.nix_2_3;
    extraOptions = ''
      netrc-file = /etc/nixos/netrc
    '';
    settings = {
      trusted-users = [ "ezemtsov" ];
      max-jobs = lib.mkDefault "auto";
    };
  };

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
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

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

  # Printer
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;

  # Audio
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05";
}
