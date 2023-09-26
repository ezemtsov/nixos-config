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
    kubelogin
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
    cinny-desktop
    unzip
    vlc
    weechat
    wget
    which
    xclip
    element-desktop
    cachix
    zstd
    nginx
    niv

    libreoffice
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.nb

    # Music packages
    audacity

    # Nix packages
    nil

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
    dotnetCorePackages.sdk_6_0

    # fsautocomplete
    (
      let
        dotnet = dotnetCorePackages.sdk_6_0;
        fsautocomplete-dll = pkgs.stdenvNoCC.mkDerivation {
          name = "fsautocomplete-dll";
          src = pkgs.fetchurl {
            url = "https://github.com/fsharp/FsAutoComplete/releases/download/v0.63.1/fsautocomplete.0.63.1.nupkg";
            sha256 = "sha256:13hl4a913al5yvnadyw19y8afw9sprazsdjhcndn2gc3v9vxb90b";
          };
          nativeBuildInputs = [ pkgs.unzip ];
          buildCommand = ''
            mkdir -p $out/bin $out/share
            unzip $src -d $out/share
            echo $out/share/tools
          '';
        };
      in
      pkgs.writeShellApplication {
        name = "fsautocomplete";
        runtimeInputs = [
          dotnet
          fsautocomplete-dll
        ];
        text = ''
          export DOTNET_ROOT=${dotnet}
          unset DOTNET_SYSTEM_GLOBALIZATION_INVARIANT
          dotnet ${fsautocomplete-dll}/share/tools/net6.0/any/fsautocomplete.dll "$@"
        '';
      })
  ];
}
