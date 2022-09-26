{ config, pkgs, lib, ... }:

let
  home-manager = fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in
{
  imports = [ (import home-manager { }).nixos ];

  # Define a user account
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
  };

  home-manager.users.ezemtsov = {
    xsession.windowManager.i3 = {
      enable = true;
      config = rec {
        menu = "${pkgs.rofi}/bin/rofi -show";
        bars = [{
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        }];
        modifier = "Mod4";
        startup = [
          { command = "hsetroot -solid \"#444444\""; }
        ];
        terminal = "alacritty";
        keybindings =
          let
            execNoStartupId = s: "exec --no-startup-id ${s}";
          in lib.mkOptionDefault {
            "${modifier}+Shift+l" = execNoStartupId "${pkgs.xsecurelock}/bin/xsecurelock";
            "${modifier}+Shift+m" = execNoStartupId "xrandr --output eDP-1 --primary --auto --output DP-1-1-8 --off";
            "${modifier}+m" = execNoStartupId "xrandr --output eDP-1 --off --output DP-1-1-8 --auto --primary";
          };
        window = {
          titlebar = false;
          border = 1;
        };
        workspaceAutoBackAndForth = true;
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
            { block = "keyboard_layout";
              driver = "kbddbus"; }
            { block = "battery"; }
          ];
          icons = "awesome";
          theme = "bad-wolf";
          settings = {
            theme = {
              name = "bad-wolf";
              overrides = {
                good_bg = "#e39866";
              };
            };
          };
        };
      };
    };
  };
}
