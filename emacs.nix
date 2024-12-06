{ pkgs }:

let
  inherit (pkgs)
    fetchFromGitHub
    callPackage
    emacsPackages
    emacsPackagesFor
  ;

  emacs = pkgs.emacs30;

in
(emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
  (exwm.overrideDerivation (o: {
    # https://github.com/ch11ng/exwm/issues/759
    postInstall = ''
      cd $out/share/emacs/site-lisp/elpa/exwm-${o.version}
      sed -i '/(cl-pushnew xcb:Atom:_NET_WM_STATE_HIDDEN exwm--ewmh-state)/d' exwm-layout.el
      rm exwm-layout.elc
    '';
  }))
  xelb

  i3bar
  exwm-modeline
  vertico-posframe

  all-the-icons
  buffer-move
  cape
  cl-lib
  cmake-mode
  color-theme-sanityinc-tomorrow
  consult
  company
  corfu
  dockerfile-mode
  dumb-jump
  eglot-fsharp
  envrc
  jinx
  mu4e
  exec-path-from-shell
  format-all
  fsharp-mode
  geiser
  geiser-guile
  go-mode
  google-c-style
  hcl-mode
  highlight-indentation
  impatient-mode
  jinja2-mode
  json-mode
  kubel
  magit
  marginalia
  markdown-preview-mode
  multiple-cursors
  nginx-mode
  nix-mode
  orderless
  pdf-tools
  projectile
  protobuf-mode
  python-mode
  rainbow-delimiters
  rainbow-mode
  restclient
  rotate
  rust-mode
  sudo-edit
  tide
  transient
  treesit-grammars.with-all-grammars
  typescript-mode
  undo-tree
  vertico
  vterm
  vterm-toggle
  web-mode
  which-key
  winum
  yaml-mode
  yasnippet
  yasnippet-snippets
  jupyter
])
