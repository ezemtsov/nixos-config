{ pkgs }:

let
  inherit (pkgs)
    fetchFromGitHub
    callPackage
    emacsPackages
    emacsPackagesFor
    emacs29
  ;

in
(emacsPackagesFor emacs29).emacsWithPackages (epkgs:
  with epkgs; [
    buffer-move
    cape
    cl-lib
    cmake-mode
    consult
    corfu
    dockerfile-mode
    dumb-jump
    eglot-fsharp
    emojify
    envrc
    exec-path-from-shell
    flycheck
    forge
    format-all
    fsharp-mode
    hcl-mode
    jinja2-mode
    magit
    markdown-preview-mode
    multiple-cursors
    nix-mode
    orderless
    protobuf-mode
    python-mode
    rainbow-delimiters
    rainbow-mode
    restclient
    rotate
    sudo-edit
    transient
    treesit-grammars.with-all-grammars
    undo-tree
    vterm
    vertico
    vterm-toggle
    web-mode
    which-key
    winum
    yaml-mode
    yasnippet
  ]
)
