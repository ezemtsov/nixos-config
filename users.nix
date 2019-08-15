{ config, pkgs, ... }:

{
# Define a user account
  users.defaultUserShell = pkgs.fish;
  users.extraUsers.ezemtsov = {
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
  };

  security.sudo = {
    enable = true;
  };

}
