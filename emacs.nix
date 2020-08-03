{ pkgs }:

with pkgs; with emacsPackagesNg;
  let
    emacsWithPackages = (emacsPackagesNgGen emacsGit).emacsWithPackages;

  in emacsWithPackages (epkgs:
    (with epkgs.melpaPackages; [
      # lsp-mode-pinned
      # vterm
      # vterm-toggle
      # telega
    ]))
