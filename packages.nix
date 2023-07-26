# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by otherlinux NixOS options (e.g. emacs)

{ config, pkgs, lib, ... }:

let
  # nixos-23.05 channel
  nixos = import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b.tar.gz";
    sha256 = "sha256:1xi53rlslcprybsvrmipm69ypd3g3hr7wkxvzc73ag8296yclyll";
  }) { config.allowUnfree = true; };

  unstable = import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/ac1acba43b2f9db073943ff5ed883ce7e8a40a2c.tar.gz";
    sha256 = "sha256:0gl7wxjnsk9fn6ck5dlv629nvs6vj42w49bb27ysxn2xgl0zzy4p";
  }) {
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "openssl-1.1.1u" ];
  };

  emacs = import (builtins.fetchGit {
    url = "https://github.com/nix-community/emacs-overlay.git";
    rev = "8557a967260b6f6fca567dcf6d1dee47aa71871f";
  });

  my = (pkgs.callPackage ./packages/default.nix { });
in
{
  # Configure the Nix package manager
  nixpkgs = {
    pkgs = nixos;
    config.allowUnfree = true;
    overlays = [ emacs ];
  };

  # Gnome apps require dconf to remember default settings
  programs.dconf.enable = true;

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    azure-cli
    azure-storage-azcopy
    binutils-unwrapped
    blueman
    breeze-icons
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
    chromium
    unstable.cinny-desktop
    unzip
    vlc
    weechat
    wget
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
  ];

  imports = [ "${nixos.home-manager.src}/nixos/default.nix" ];
  home-manager.useGlobalPkgs = true;
  home-manager.users.ezemtsov = {
    home.stateVersion = config.system.stateVersion;
    xsession.windowManager.i3 = {
      enable = true;
      config = rec {
        menu = "${pkgs.rofi}/bin/rofi -show";
        bars = [{
          statusCommand = ''
            ${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml
          '';
        }];
        modifier = "Mod4";
        startup = [
          { command = "hsetroot -solid \"#444444\""; }
        ];
        terminal = "${pkgs.alacritty}/bin/alacritty";
        keybindings =
          let
            execNoStartupId = s: "exec --no-startup-id ${s}";
          in
          lib.mkOptionDefault {
            "${modifier}+Shift+l" = execNoStartupId "${pkgs.xsecurelock}/bin/xsecurelock";
            "${modifier}+Shift+m" = execNoStartupId ''
              xrandr --output eDP-1 --primary --auto --output DP-1-1-8 --off'';
            "${modifier}+m" = execNoStartupId ''
              xrandr --output eDP-1 --off --output DP-1-1-8 --auto --primary'';
            "${modifier}+o" = execNoStartupId "${pkgs.wmfocus}/bin/wmfocus";
            "${modifier}+Print" = execNoStartupId "${pkgs.flameshot}/bin/flameshot gui";
          };
        window = {
          titlebar = false;
          border = 1;
        };
        workspaceAutoBackAndForth = true;
      };
    };

    services.keynav.enable = true;

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrains Mono";
            style = "Regular";
          };
          bold = {
            family = "JetBrains Mono";
            style = "Bold";
          };
          italic = {
            family = "JetBrains Mono";
            style = "Italic";
          };
        };
        key_bindings = [
          {
            key = "Up";
            mods = "Control";
            action = "ScrollPageUp";
          }
          {
            key = "Down";
            mods = "Control";
            action = "ScrollPageDown";
          }
          {
            key = "I";
            mods = "Control";
            action = "ToggleViMode";
          }
          {
            key = "W";
            mods = "Alt";
            action = "CopySelection";
          }
          {
            key = "Y";
            mods = "Control";
            action = "PasteSelection";
          }
          {
            key = "G";
            mods = "Control";
            action = "ClearSelection";
          }
          {
            key = "Space";
            mods = "Control";
            action = "ToggleNormalSelection";
            mode = "Vi";
          }
          {
            key = "Left";
            mods = "Control";
            action = "SemanticLeft";
            mode = "Vi";
          }
          {
            key = "Right";
            mods = "Control";
            action = "SemanticRightEnd";
            mode = "Vi";
          }
        ];
      };
    };

    programs.rofi = {
      enable = true;
      theme = "Arc-Dark";
      extraConfig = {
        modi = "combi";
        show-icons = true;
        hide-scrollbar = true;
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          blocks = [
            {
              block = "networkmanager";
              primary_only = true;
              ap_format = "{ssid}";
              device_format = "{icon}{ap}";
            }
            { block = "disk_space"; }
            { block = "sound"; }
            {
              block = "time";
              interval = 60;
              format = "%a %d/%m %R";
            }
            {
              block = "keyboard_layout";
              driver = "kbddbus";
            }
            { block = "battery"; }
          ];
          icons = "awesome";
          settings = {
            theme = {
              name = "plain";
              overrides.good_fg = "#aaaaaa";
            };
          };
        };
      };
    };
  };

}
