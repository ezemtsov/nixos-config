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

    services.grobi =
      let external = [ "HDMI-1" "DP-8" "DP-9" ];
      in {
        enable = true;
        rules = map
          (o: {
            name = o;
            outputs_connected = [ o ];
            configure_single = o;
            primary = true;
          })
          external ++ [{
          name = "eDP-1";
          outputs_disconnected = external;
          configure_single = "eDP-1";
          primary = true;
        }];
      };

    programs.i3status-rust.enable = true;
    programs.i3status-rust.bars.default = {
      blocks = [
        { block = "net"; format = " $icon {$signal_strength $ssid} "; }
        { block = "disk_space"; }
        { block = "sound"; }
        { block = "time"; interval = 60; }
        { block = "keyboard_layout"; driver = "xkbswitch"; }
        { block = "battery"; }
      ];
      icons = "awesome5";
      settings.theme.overrides = {
        idle_bg = "#282A2E";
        good_bg = "#282A2E";
        warning_bg = "#282A2E";
        critical_bg = "#282A2E";
        info_bg = "#282A2E";
        separator_bg = "#282A2E";
      };
    };
  };
}
