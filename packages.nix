# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  emacsOverlay =
    fetchTarball
      https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
    overlays = [ (import emacsOverlay) ];
  };

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    alacritty
    cachix
    cmake
    curl
    feh
    file
    flameshot
    gcc
    gimp
    git
    gnome3.nautilus
    gnumake
    gtk3
    gvfs
    htop
    i3lock
    ispell
    jupyter
    kbdd
    libtool
    manpages
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    okular
    openjdk
    pulseaudio-ctl
    python3
    spotify
    sqlite
    tdesktop
    transmission
    tree
    unstable.chromium
    unstable.nodejs
    unzip
    vlc
    wget
    
    # Haskell packages
    ghc
    hlint
    stack
    # stack2nix  --package is broken
    haskellPackages.stylish-haskell
  ];
}
