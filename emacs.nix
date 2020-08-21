{ pkgs }:

with pkgs; with emacsPackagesNg;
  let
    unstable = import <unstable> {};
    emacsWithPackages = (emacsPackagesNgGen unstable.emacs).emacsWithPackages;

  in emacsWithPackages (epkgs:
    (with epkgs.melpaPackages; [
      # lsp-mode-pinned
      # vterm
      # vterm-toggle
      # telega
    ]))
