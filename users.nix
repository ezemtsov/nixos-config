{ config, pkgs, ... }:

{
# Define a user account
  users.defaultUserShell = pkgs.fish;
  users.extraUsers.ezemtsov = {
    extraGroups = [ "wheel"
                    "vboxusers"
                    "networkmanager"
                    "libvirtd"
                    "wireshark"
                    "docker"
                    "audio"
                    "jackaudio" ];
    description = "Evgeny Zemtsov";
    isNormalUser = true;
    uid = 1000;
  };

  security.sudo = {
    enable = true;
  };

}
