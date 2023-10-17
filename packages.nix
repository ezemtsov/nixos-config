{ config, pkgs, lib, ... }:

let
in {
  # Gnome apps require dconf to remember default settings
  programs.dconf.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    azure-cli
    azure-storage-azcopy
    binutils-unwrapped
    blueman
    breeze-icons
    cachix
    chromium
    cinny-desktop
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
    gnumake
    google-cloud-sdk
    gtk3
    hsetroot
    htop
    hybridreverb2
    i3lock
    inetutils
    ispell
    jq
    jupyter
    kind
    kubectl
    kubelogin
    libnotify
    libtool
    lingot
    lnav
    man-pages
    gnome.nautilus
    nginx
    nheko
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
    proton-caller
    pyright
    ripgrep
    slack
    spotify
    sqlite
    signal-desktop
    tailscale
    tdesktop
    transmission
    tree
    unzip
    vlc
    weechat
    wget
    which
    xclip
    zstd

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb
    
    # Music packages
    audacity

    # Nix packages
    nil
    niv
    nix-diff
    nix-index
    nixpkgs-fmt

    # Chicken packages
    chicken

    # CLisp packages
    sbcl
    lispPackages.quicklisp

    # Rust packages
    rustc
    cargo
    rustup
    rust-analyzer

    # Haskell packages
    # haskell.compiler.ghc883
    haskellPackages.ghcide
    haskellPackages.cabal-install

    # Python packages with dependencies for lsp-bridge
    (python3.withPackages (p: with p; [
      epc
      orjson
      sexpdata
      six
      paramiko
      rapidfuzz
    ]))

    # .NET packages
    (dotnetCorePackages.combinePackages (with dotnetCorePackages; [
      sdk_6_0
      sdk_7_0
    ]))
    fsautocomplete
  ];
}
