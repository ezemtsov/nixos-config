# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
  emacs = import (builtins.fetchGit {
    url = "https://github.com/nix-community/emacs-overlay.git";
    rev = "274db48d3a88a44d742c2543afc8e3f4e6be9189";
  });

  my = (pkgs.callPackage ./packages/default.nix { });
in
{
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ emacs ];
    config.permittedInsecurePackages = [
      "python3.9-mistune-0.8.4"
    ];
  };

  # Gnome apps require dconf to remember default settings
  programs.dconf.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    # my.iconnconfig
    # my.renoise
    # my.x32edit
    my.fsautocomplete

    azure-cli
    azure-storage-azcopy
    binutils-unwrapped
    blueman
    breeze-icons
    chromium
    cmake
    curl
    direnv
    element-desktop
    ffmpeg
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
    i3lock
    ispell
    jq
    jupyter
    kind
    kubectl
    libnotify
    libtool
    lingot
    lnav
    lsd
    lsp-plugins
    man-pages
    nix-index
    nixpkgs-fmt
    nodejs
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    nushell
    okular
    openjdk
    pavucontrol
    postgresql
    pyright
    quasselClient
    silver-searcher
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
    xclip
    zoom-us

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb

    # Music packages
    unstable.cadence
    unstable.audacity
    supercollider

    # Nix packages
    unstable.cachix
    unstable.rnix-lsp

    # Chicken packages
    chicken

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

    # Python packages
    python3
    python3Packages.pip
  ];

}
