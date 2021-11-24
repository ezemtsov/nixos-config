# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
  emacsGit = import (builtins.fetchTarball
    https://github.com/nix-community/emacs-overlay/archive/532be17.tar.gz);

  myDotnet = (pkgs.callPackage /home/ezemtsov/Resoptima/irma/support/sdk.nix {}).dotnet;

  my = (pkgs.callPackage ./packages/default.nix {});

in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;

    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = pkgs: {};

    overlays = [
      emacsGit
    ];
  };

  # Gnome alps require dconf to remember default settings
  programs.dconf.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    # sunvox
    my.iconnconfig
    my.renoise
    my.x32edit
    my.bitwig-studio3

    binutils-unwrapped
    blueman
    breeze-icons
    chromium
    cmake
    curl
    direnv
    file
    fish
    gcc
    gimp
    gitFull
    gnome3.nautilus
    gnumake
    gtk3
    gvfs
    hsetroot
    htop
    hybridreverb2
    ispell
    jupyter
    kind
    kubectl
    libnotify
    libtool
    lingot
    lnav
    lsd
    lsp-plugins
    manpages
    nodejs
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    okular
    openjdk
    postgresql
    quasselClient
    slack
    spotify
    sqlite
    tdesktop
    transmission
    tree
    unstable.cachix
    unzip
    vlc
    wget
    wireshark

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb

    # Music packages
    unstable.cadence
    unstable.jack2Full
    # unstable.pulseaudioFull
    unstable.audacity
    supercollider

    nushell
    zoom-us

    # CLisp packages
    unstable.alsaLib
    unstable.sbcl
    unstable.lispPackages.quicklisp

    # Rust packages
    unstable.rustc
    unstable.cargo
    unstable.rustup
    unstable.rust-analyzer
    unstable.carnix

    # Haskell packages
    # haskell.compiler.ghc883
    unstable.haskellPackages.ghcide
    haskellPackages.cabal-install

    # Dotnet packages
    unstable.jetbrains.rider
    myDotnet
    dotnetPackages.Nuget

    # Python packages
    python3
    python3Packages.pip
    python-language-server
    python3Packages.pytest
  ];

}
