{ pkgs }:
let
  emacsPackage = pkgs.emacs;
  emacsWithPackages =
    (pkgs.emacsPackagesGen emacsPackage).emacsWithPackages;
in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [
    # vterm
    # vterm-toggle
    # telega
  ])
)
