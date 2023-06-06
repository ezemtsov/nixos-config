{ config, pkgs, lib, ... }:

{
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
      "plex"
    ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
  };
}
