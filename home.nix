{ config, pkgs, lib, ... }@args:

{
  # Define a user account
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    alias k="kubectl"
    alias emasc="emacs"
    eval (direnv hook fish)
    source (find '${pkgs.emacsPackages.vterm}' -name 'emacs-vterm.fish')
  '';
  users.defaultUserShell = pkgs.fish;

  users.extraUsers.ezemtsov = {
    extraGroups = [
      "wheel"
      "vboxusers"
      "networkmanager"
      "libvirtd"
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
    home.enableNixpkgsReleaseCheck = false;

    services.dunst.enable = true;

    services.grobi = {
      enable = true;
      rules = [
        {
          name = "USB-C";
          outputs_connected = [ "DP-2" ];
          configure_single = "DP-8";
          primary = true;
          automic = true;
        }
        {
          name = "HDMI";
          outputs_connected = [ "HDMI-1" ];
          configure_single = "HDMI-1";
          primary = true;
          automic = true;
        }
        {
          name = "Mobile";
          outputs_disconnected = [ "DP-8" "HDMI-1" ];
          configure_single = "eDP-1";
          primary = true;
          automic = true;
        }
      ];
    };

    programs.i3status-rust.enable = true;
    programs.i3status-rust.bars.default = {
      blocks = [
        {
          block = "net";
          format = " $icon {$signal_strength $ssid|Wired connection} ";
        }
        { block = "disk_space"; }
        {
          block = "time";
          interval = 60;
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
        {
          block = "keyboard_layout";
          driver = "xkbswitch";
        }
        { block = "battery"; }
      ];
      icons = "awesome5";
      settings.theme.overrides =
        let
          bg = "#282A2E";
        in {
          idle_bg = bg;
          good_bg = bg;
          warning_bg = bg;
          critical_bg = bg;
          info_bg = bg;
          separator_bg = bg;
        };
    };
  };
}
