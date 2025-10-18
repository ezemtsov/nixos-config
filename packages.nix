{ config, pkgs, lib, sources, ... }:

let
  dotnet = with pkgs.dotnetCorePackages; (combinePackages [
    sdk_8_0
    sdk_9_0
    runtime_8_0
    runtime_9_0
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
  };

  programs.thunderbird.enable = true;
  programs.evolution.enable = true;
  # Sideloading APK
  programs.adb.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    binutils-unwrapped
    cachix
    chromium
    firefox
    cmake
    curl
    direnv
    ffmpeg-full
    file
    fish
    gcc
    gimp
    gitFull
    (btop.override { rocmSupport = true; })
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
    signal-desktop
    jq
    eaglemode
    ryzenadj
    virt-manager

    libreoffice
    nuspell
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.ru_RU

    # azure-cli
    azure-storage-azcopy
    google-cloud-sdk

    # Gaming
    lutris
    wineWowPackages.stable
    winetricks

    # EXWM packages
    i3status-rust
    flameshot
    grobi
    xclip
    xsecurelock
    xkb-switch

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

    # C package
    clang-tools
    gcc
    glibc.dev

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
      # kaleido
      matplotlib
      jupyter
      kubernetes
      debugpy
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
