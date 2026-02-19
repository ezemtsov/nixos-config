{ pkgs }:

pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs-pgtk;
  config = ./dotfiles/emacs/init.el;

  # Additional packages not automatically detected from use-package
  # declarations
  extraEmacsPackages = epkgs: with epkgs; [
    treesit-grammars.with-all-grammars
    config.programs.ewm.ewmPackage
  ] ++ (with epkgs.melpaPackages; [
    vterm
    jinx
    telega
  ]);
}
