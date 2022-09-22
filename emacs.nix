{ pkgs }:

with pkgs;
with emacsPackagesNg;

let
  emacsWithPackages = (emacsPackagesFor emacsNativeComp).emacsWithPackages;

in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [
    exwm
    xelb
    vterm
  ]))
