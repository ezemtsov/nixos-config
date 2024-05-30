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
