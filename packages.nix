{ config, pkgs, lib, ... }:

let
  dotnet = with pkgs.dotnetCorePackages; (combinePackages [
    sdk_6_0
    sdk_7_0
    sdk_8_0
    runtime_6_0
    runtime_7_0
    runtime_8_0
  ]);

in {
  # Gnome apps require dconf to remember default settings
  programs.dconf.enable = true;

  # Allow testing .NET compiled executables
  programs.nix-ld.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    aws-workspaces
    azure-cli
    azure-storage-azcopy
    binutils-unwrapped
    blueman
    breeze-icons
    cachix
    chromium
    cmake
    curl
    direnv
    ffmpeg
    file
    fish
    gcc
    gimp
    gitFull
    nemo
    gnumake
    google-cloud-sdk
    gtk3
    hsetroot
    htop
    hybridreverb2
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
    nginx
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    okular
    openjdk
    openssl
    pavucontrol
    postgresql
    proton-caller
    ripgrep
    signal-desktop
    slack
    spotify
    sqlite
    tailscale
    tdesktop
    transmission_4
    tree
    unzip
    vlc
    weechat
    wget
    which
    zstd

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb

    # Exwm packages
    i3status-rust
    networkmanagerapplet
    flameshot
    grobi
    xclip
    xsecurelock
    xkb-switch

    # Music packages
    audacity

    # Nix packages
    nil
    npins
    nix-diff
    nixpkgs-fmt

    # Chicken packages
    chicken

    # # CLisp packages
    # sbcl
    # lispPackages.quicklisp

    # Rust packages
    rustc
    rustup

    # Haskell packages
    haskellPackages.cabal-install
    haskellPackages.ghcide

    # Python packages
    pyright
    python3

    # .NET packages
    dotnet
    (fsautocomplete.overrideDerivation (o: { dotnet-runtime = dotnet; }))

    # Go packages
    go
    gopls

    # Guile
    guile

    # JSON/HTML
    vscode-langservers-extracted

    # Javascript packages
    nodejs
    nodePackages.typescript-language-server

    # NixOS helpers
    (writeShellScriptBin "nixos-switch" (builtins.readFile ./nixos-switch))
  ];
}
