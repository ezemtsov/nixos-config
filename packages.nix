# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  emacsOverlay =
    fetchTarball
      https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
  # all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = pkgs: {
      # unstable = import unstableTarball {
      #   config = config.nixpkgs.config;
      # };
    };
    overlays = [ (import emacsOverlay) ];
  };

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    alacritty
    binutils-unwrapped
    blueman
    cachix
    chromium
    cmake
    curl
    dunst
    file
    flameshot
    gcc
    gimp
    gitFull
    gnome3.nautilus
    gnumake
    gtk3
    gvfs
    hsetroot
    htop
    i3lock
    i3status-rust
    ispell
    jupyter
    libtool
    lnav
    lsd
    manpages
    nodejs
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    okular
    openjdk
    postgresql
    pulseaudio-ctl
    slack
    spotify
    sqlite
    tdesktop
    transmission
    tree
    unzip
    vlc
    vscode
    wget

    qjackctl
    jack2Full
    unstable.cadence
    supercollider

    nushell
    zoom-us

    # Haskell packages
    haskell.compiler.ghc883
    unstable.haskellPackages.ghcide
    haskellPackages.cabal-install

    (dotnetCorePackages.combinePackages
      [ dotnetCorePackages.sdk_3_0
        unstable.dotnetCorePackages.sdk_3_1
      ]
    )
    dotnetPackages.Nuget

    python3
    python37Packages.pip
    python37Packages.python-language-server
    python37Packages.pytest
  ];

}
