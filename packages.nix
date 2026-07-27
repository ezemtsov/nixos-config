{ config, lib, pkgs, sources, ... }:

let
  falconSensor = pkgs.callPackage ./crowdstrike { };
  crowdstrikeCidSecret = ./secrets/crowdstrike-cid.age;
  hasCrowdstrikeCidSecret = builtins.pathExists crowdstrikeCidSecret;
in
{
  # Allow testing .NET compiled executables and Android emulator
  programs.nix-ld.enable = true;

  # Configure git
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user.name  = "Evgeny Zemtsov";
      user.email = "eugene.zemtsov@gmail.com";
    };
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ezemtsov" ];
  };

  services.flatpak.enable = true;

  age.secrets.crowdstrike-cid = lib.mkIf hasCrowdstrikeCidSecret {
    file = crowdstrikeCidSecret;
    path = "/run/secrets/crowdstrike-cid";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.packages = [ falconSensor.unwrapped ];

  systemd.tmpfiles.rules = falconSensor.tmpfilesRules;

  systemd.services.falcon-sensor-configure = lib.mkIf hasCrowdstrikeCidSecret {
    before = [ "falcon-sensor.service" ];
    after = [
      "agenix-install-secrets.service"
      "systemd-tmpfiles-setup.service"
    ];
    requiredBy = [ "falcon-sensor.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      cid="$(${pkgs.coreutils}/bin/tr -d '\n\r ' < ${config.age.secrets.crowdstrike-cid.path})"
      if [ -z "$cid" ]; then
        echo "CrowdStrike CID secret is empty" >&2
        exit 1
      fi

      /opt/CrowdStrike/falconctl -s --cid="$cid" -f
    '';
  };

  systemd.services.falcon-sensor = lib.mkMerge [
    {
      wantedBy = [
        "sysinit.target"
        "multi-user.target"
      ];
      after = [ "systemd-tmpfiles-setup.service" ];
    }

    (lib.mkIf hasCrowdstrikeCidSecret {
      after = [ "falcon-sensor-configure.service" ];
      requires = [ "falcon-sensor-configure.service" ];
    })

    (lib.mkIf (!hasCrowdstrikeCidSecret) {
      serviceConfig.ExecCondition = [ "/opt/CrowdStrike/falconctl -g --cid" ];
    })
  ];

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    (btop.override { rocmSupport = true; })
    htop
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
    yq-go
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
    fractal
    zstd
    unixtools.netstat

    mermaid-cli
    loupe

    # graphite
    firecracker

    reaper

    libreoffice
    nuspell
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.ru_RU

    # AI Stuff
    claude-code
    claude-monitor
    codex
    playwright
    playwright-driver.browsers
    ghostty
    graphite-cli

    # cloud SDK
    azure-storage-azcopy
    (google-cloud-sdk.withExtraComponents
      (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]))

    awscli2

    # Gaming
    wineWow64Packages.stable
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

    # Crowdstrike
    falconSensor

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

    # Go packages
    go
    gopls

    # Guile
    guile

    # JSON/HTML
    vscode-langservers-extracted

    # Javascript packages
    bun

    # Android development
    gradle
    android-tools

    # NixOS helpers
    (writeShellScriptBin "nixos-switch" (builtins.readFile ./nixos-switch))
    (writeShellScriptBin "screenshot" ''
      ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${satty}/bin/satty --filename - --fullscreen --early-exit --copy-command ${wl-clipboard}/bin/wl-copy
    '')

    (pkgs.callPackage "${sources.agenix}/pkgs/agenix.nix" {})
  ];
}
