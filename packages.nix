{ config, pkgs, lib, ... }:

let
  unstable = import config.sources.unstable {
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "openssl-1.1.1u" ];
  };

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
    chromium
    cmake
    curl
    direnv
    dolphin
    ffmpeg
    file
    fish
    gcc
    gimp
    gitFull
    gnumake
    gtk3
    gvfs
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
    libnotify
    libtool
    lingot
    lnav
    lsd
    lsp-plugins
    man-pages
    nheko
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
    proton-caller
    pyright
    silver-searcher
    slack
    spotify
    sqlite
    tailscale
    tdesktop
    transmission
    tree
    unstable.cinny-desktop
    unzip
    vlc
    weechat
    wget
    which
    xclip

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb

    # Music packages
    unstable.audacity

    # Nix packages
    unstable.rnix-lsp

    # Chicken packages
    chicken

    # CLisp packages
    unstable.sbcl
    unstable.lispPackages.quicklisp

    # Rust packages
    unstable.rustc
    unstable.cargo
    unstable.rustup
    unstable.rust-analyzer

    # Haskell packages
    # haskell.compiler.ghc883
    unstable.haskellPackages.ghcide
    haskellPackages.cabal-install

    # Python packages
    python3

    # .NET packages
    unstable.dotnetCorePackages.sdk_7_0
  ];
}
