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
        keybindings = lib.mkOptionDefault {
          "${modifier}+Return" = "exec --no-startup-id alacritty";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+q" = "split toggle";
          "${modifier}+Shift+m" = "exec --no-startup-id xrandr --output eDP-1 --primary --auto --output DP-1-1-8 --off";
          "${modifier}+m" = "exec --no-startup-id xrandr --output eDP-1 --off --output DP-1-1-8 --auto --primary";
        };
      };
      extraConfig = ''
        default_border pixel 1
        hide_edge_borders none
        workspace_auto_back_and_forth yes
      '';
    };

    programs.rofi = {
      enable = true;
      theme = "gruvbox-dark-soft";
      extraConfig = {
        modi = "combi";
        show-icons = true;
        hide-scrollbar = true;
      };
    };

    programs.i3status-rust = {
      enable = true;
    };
  };
}
