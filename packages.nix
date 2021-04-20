# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
  emacsGit = import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz);

  myDotnet = (pkgs.callPackage /home/ezemtsov/Resoptima/irma/support/sdk.nix {}).dotnet;

  my = (pkgs.callPackage ./packages/default.nix {});

in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;

    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = pkgs: {
    };

    # Fixing CVE-2020-13949 according to nixpkgs suggestion
    config.permittedInsecurePackages = [
      "thrift-0.13.0"
    ];

    overlays = [
      emacsGit
    ];
  };

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    # sunvox
    my.iconnconfig

    binutils-unwrapped
    blueman
    breeze-icons
    unstable.cachix
    chromium
    cmake
    curl
    direnv
    dunst
    file
    fish
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
    hybridreverb2
    kind
    ispell
    jupyter
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
    slack
    spotify
    sqlite
    tdesktop
    transmission
    tree
    unzip
    vlc
    wget

    # Music packages
    unstable.cadence
    unstable.jack2Full
    # unstable.pulseaudioFull
    unstable.audacity
    supercollider
    (unstable.renoise.overrideAttrs(old: {
      src = fetchurl {
        url = "https://files.renoise.com/demo/Renoise_3_3_2_Demo_Linux.tar.gz";
        sha256 = "0d9pnrvs93d4bwbfqxwyr3lg3k6gnzmp81m95gglzwdzczxkw38k";
      };
    }))
    (x32edit.overrideAttrs(old: {
      version = "4.2";
      src = fetchurl {
        url = "https://mediadl.musictribe.com/download/software/behringer/X32/X32-Edit_LINUX_4.2.tar.gz";
        sha256 = "1wkd8qh1brfw7j4qdr109hcqbjlmik7jrybagpzgaxin75rxhx6g";
      };
    }))
    (unstable.bitwig-studio3.overrideAttrs (oldAttrs: rec {
      version = "3.3.1";
      jre = /home/ezemtsov/Downloads/Bitwig/Linux/patch/bitwig.jar;
      src = /home/ezemtsov/Downloads/Bitwig/Linux/bitwig-studio-3.3.1.deb;
      postFixup = ''
        ${oldAttrs.postFixup}
        find -L $out -name "bitwig.jar" -exec cp ${jre} {} \;
      '';
    }))

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
    jetbrains.rider
    (dotnetCorePackages.combinePackages
      [
        myDotnet
        unstable.dotnetCorePackages.sdk_5_0
        dotnetPackages.Fantomas
      ]
    )
    dotnetPackages.Nuget

    # Python packages
    python3
    python37Packages.pip
    unstable.python-language-server
    python37Packages.pytest
    (with python37Packages;
      buildPythonPackage {
      name = "parquet-cli";
      src = fetchFromGitHub {
        owner = "chhantyal";
        repo = "parquet-cli";
        rev = "588b738a3f1661cba62b11e6a1ac6fd6d709f0eb";
        sha256 = "0m0zsk3d56fmiwnqqq6qfkcf5zk63ydqz53qn9ykjcvkkmdgbrd1";
      };
      propagatedBuildInputs = [ pandas pyarrow ];
    })
  ];

}
