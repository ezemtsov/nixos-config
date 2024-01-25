{ config, pkgs, lib, ... }@args:

{
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

    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "default";
        extraConfig = ''
          user_pref("ui.key.menuAccessKeyFocuses", false);
          user_pref("browser.link.open_newwindow", 1);
          user_pref("browser.tabs.inTitlebar", 0);
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
        '';
        userChrome = ''
          /* Hide Tab bar with only one Tab - [110] */
          #tabbrowser-tabs .tabbrowser-tab:only-of-type,
          #tabbrowser-tabs .tabbrowser-tab:only-of-type + #tabbrowser-arrowscrollbox-periphery{
            display:none !important;
          }
          #tabbrowser-tabs, #tabbrowser-arrowscrollbox {min-height:0!important;}
          /* #TabsToolbar:not(:hover) */ #alltabs-button {display:none !important;}
        '';
      };
    };

    services.grobi = {
      enable = true;
      rules = [
        {
          name = "USB-C";
          outputs_connected = [ "DP-1-1-8" ];
          configure_single = "DP-1-1-8";
          primary = true;
          automic = true;
        }
        {
          name = "HDMI";
          outputs_connected = [ "DP-3" ];
          configure_single = "DP-3";
          primary = true;
          automic = true;
        }
        {
          name = "Mobile";
          outputs_disconnected = [ "DP-1-1-8" "DP-3" ];
          configure_single = "eDP-1";
          primary = true;
          automic = true;
        }
      ];
    };

    services.flameshot.enable = true;
    services.dunst.enable = true;
  };

}
