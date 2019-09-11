# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;

in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    config.chromium = {
      # enablePepperFlash = true; 
    };
    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };

  };

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    unstable.i3status-rust
    alacritty
    unstable.chromium
    curl
    evince
    feh
    file
    flameshot
    gimp
    iw 
    git
    gnome3.nautilus
    htop
    manpages
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    openjdk
    pavucontrol
    spotify
    sqlite
    tdesktop
    transmission
    tree
    unzip
    vlc
    wget
    xkblayout-state
    unstable.nodejs
    ghc
    hlint
    stack
    ];
}
