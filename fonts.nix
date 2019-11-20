{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      font-awesome_5
      source-code-pro
      overpass
      siji
      fira-code
      fira-code-symbols
    ];
  };
}
