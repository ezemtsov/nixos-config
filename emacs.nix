{ pkgs }:

with pkgs;
with emacsPackagesNg;

let
  emacsWithPackages = (emacsPackagesNgGen emacsGcc).emacsWithPackages;

in emacsWithPackages (epkgs:
  (with epkgs.elpaPackages; [
    #xelb
  ]) ++

  (with epkgs.melpaPackages; [
    # lsp-mode-pinned
    # exwm
    vterm
    # vterm-toggle
    # telega
  ]))
