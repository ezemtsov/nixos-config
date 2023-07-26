{ config, pkgs, lib, ... }@args:

{
  imports = [
    "${(import ./sources.nix args).config.sources.home-manager}/nixos/default.nix"
  ];

  # Define a user account
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  users.extraUsers.ezemtsov = {
    extraGroups = [
      "wheel"
      "vboxusers"
      "networkmanager"
      "libvirtd"
      "wireshark"
      "docker"
    ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # There two properties are important to align home-manager with
  # global nixpkgs set.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;

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
    services.parcellite.enable = true;
    services.flameshot.enable = true;
    services.dunst.enable = true;

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
              block = "net";
              format = "{ssid}";
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
