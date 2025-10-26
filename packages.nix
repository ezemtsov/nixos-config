{ pkgs, sources, ... }:

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

  # Sideloading APK
  programs.adb.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    (btop.override { rocmSupport = true; })
    binutils-unwrapped
    cachix
    chromium
    cmake
    curl
    direnv
    eaglemode
    ffmpeg-full
    file
    firefox
    fish
    gcc
    gimp
    gitFull
    jq
    kubectl
    kubelogin
    ntfs3g
    openjdk
    openssl
    pandoc
    postgresql
    pqrs
    ripgrep
    ryzenadj
    slack
    spotify
    sqlite
    tailscale
    tdlib
    transmission_4-qt
    tree
    unzip
    virt-manager
    vlc
    wget
    which
    zstd

    libreoffice
    nuspell
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.ru_RU

    # AI Stuff
    claude-code
    claude-monitor

    # cloud SDK
    azure-storage-azcopy
    google-cloud-sdk

    # Gaming
    lutris
    wineWowPackages.stable
    winetricks

    # Audio packages
    bluetuith
    alsa-utils
    pavucontrol
    audacity

    # Nix packages
    npins
    nixd
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
    rust-analyzer
    pkg-config

    # Haskell packages
    haskellPackages.cabal-install
    haskellPackages.ghcide

    # Python packages
    pyright
    ruff
    (python3.withPackages (p: with p; [
      black
      pandas
      requests
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
    fsautocomplete

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
