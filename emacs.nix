{ pkgs }:

with pkgs;
with emacsPackagesNg;

let
  emacsWithPackages = (emacsPackagesFor emacs).emacsWithPackages;

in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [
    # exwm
    # xelb
    vterm
  ]))
