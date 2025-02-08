{ config, pkgs, lib, sources, ... }:

let
  dotnet = with pkgs.dotnetCorePackages; (combinePackages [
    sdk_7_0
    sdk_8_0
    runtime_7_0
    runtime_8_0
  ]);

in {
  # Allow testing .NET compiled executables
  programs.nix-ld.enable = true;

  # Configure git
  programs.git = {
    enable = true;
    config = {
      user.name  = "Evgeny Zemtsov";
      user.email = "eugene.zemtsov@gmail.com";
    };
  }
;
  programs.thunderbird.enable = true;

  # Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    binutils-unwrapped
    bottom
    cachix
    chromium
    firefox
    cmake
    curl
    direnv
    ffmpeg
    file
    fish
    gcc
    gimp
    gitFull
    htop
    kubectl
    kubelogin
    ntfs3g
    openjdk
    openssl
    pandoc
    postgresql
    pqrs
    ripgrep
    slack
    spotify
    sqlite
    tailscale
    tdesktop
    transmission_4-qt
    tree
    unzip
    vlc
    wget
    which
    zstd
    alacritty

    libreoffice
    nuspell
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.ru_RU

    # azure-cli
    azure-storage-azcopy
    google-cloud-sdk

    # Gaming
    gamemode
    lutris
    wineWowPackages.stable
    winetricks
    torzu

    # EXWM packages
    # i3status-rust
    # flameshot
    # grobi
    # xclip
    # xsecurelock
    # xkb-switch

    # Music packages
    alsa-utils
    pavucontrol
    audacity

    # Nix packages
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
    rust-analyzer
    pkg-config

    # Haskell packages
    haskellPackages.cabal-install
    haskellPackages.ghcide

    # Python packages
    pyright
    ruff
    (python3.withPackages (p: with p; [
      pandas
      plotly
      pyarrow
      kaleido
      matplotlib
      jupyter
    ]))

    # .NET packages
    dotnet
    csharp-ls

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
    (pkgs.callPackage "${sources.agenix}/pkgs/agenix.nix" {})
  ];
}
