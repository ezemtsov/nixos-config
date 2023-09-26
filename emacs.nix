{ pkgs }:

with pkgs;

(emacsPackagesFor emacs29).emacsWithPackages (epkgs: with epkgs; [
    # exwm
    # xelb
    lsp-bridge
    melpaPackages.vterm
  ]
)
