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
    # aws-workspaces
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
    nginx
    ntfs3g
    numix-cursor-theme
    numix-icon-theme
    numix-solarized-gtk-theme
    openjdk
    openssl
    pavucontrol
    postgresql
    ripgrep
    slack
    spotify
    sqlite
    tailscale
    tdesktop
    transmission_4
    tree
    unzip
    vlc
    wget
    which
    zstd
    beeper
    pqrs
    pandoc
    wpa_supplicant_gui
    wpa_supplicant

    libreoffice
    nuspell
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.ru_RU

    azure-cli
    azure-storage-azcopy
    google-cloud-sdk

    plasma-browser-integration
    (pkgs.writeShellScriptBin "vterm" ''
        emacsclient -c -e '(let ((default-directory "~/")) (vterm))'
    '')

    # nirix
    # alacritty
    # waybar
    # fuzzel
    # wlrctl
    # (pkgs.writeShellScriptBin "fuzzel" ''
    #     emacsclient -e "(consult-buffer)"
    # '')

    i3status-rust
    flameshot
    grobi
    xclip
    xsecurelock
    xkb-switch

    emacs-lsp-booster

    # Music packages
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
    (fsautocomplete.overrideDerivation (o: { dotnet-runtime = dotnet; }))
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
  ];
}
