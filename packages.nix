# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
  tvl = import (builtins.fetchGit {
    url = "https://cl.tvl.fyi/depot";
    rev = "3d006181e3a533572f1e9ccff319777c5918ad98"; }) {};
  
  my = (pkgs.callPackage ./packages/default.nix {});

in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      tvl.third_party.overlays.emacs
      tvl.third_party.overlays.tvl
    ];
  };

  # Gnome apps require dconf to remember default settings
  programs.dconf.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    # sunvox
    my.iconnconfig
    my.renoise
    my.x32edit

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
    tailscale
    tdesktop
    transmission
    tree
    unzip
    vlc
    wget
    nushell
    zoom-us
    xclip
    i3lock


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

    # Nix packages
    unstable.cachix
    unstable.rnix-lsp

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
    (with unstable.dotnetCorePackages; combinePackages [
      # sdk_3_1
      # sdk_5_0
      sdk_6_0
    ])
    dotnetPackages.Nuget

    # Python packages
    python3
    python3Packages.pip
    python-language-server
  ];

}
