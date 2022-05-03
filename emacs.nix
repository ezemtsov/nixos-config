{ pkgs }:

with pkgs;
with emacsPackagesNg;

let
  emacsWithPackages = (emacsPackagesNgGen emacsNativeComp).emacsWithPackages;

in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [
    # Desktop
    exwm
    xelb
    vterm

    # Core
    all-the-icons
    auto-package-update
    buffer-move
    centered-cursor-mode
    cl-lib
    company
    company-quickhelp
    counsel
    counsel-projectile
    direnv
    dockerfile-mode
    doom-modeline
    doom-themes
    emojify
    exec-path-from-shell
    flycheck
    flyspell-correct-ivy
    format-all
    gpastel
    lsp-mode
    lsp-treemacs
    lsp-ui
    magit
    markdown-preview-mode
    multiple-cursors
    poke-line
    projectile
    protobuf-mode
    rainbow-delimiters
    rainbow-mode
    restclient
    solaire-mode
    transient
    treemacs
    treemacs-magit
    treemacs-projectile
    undo-tree
    which-key
    winum
    yaml-mode
    yasnippet
  ]))
