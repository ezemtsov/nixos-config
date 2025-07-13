{ pkgs }:

let
  inherit (pkgs)
    fetchFromGitHub
    callPackage
    emacsPackages
    emacsPackagesFor
    emacsWithPackagesFromUsePackage
  ;

  emacs = pkgs.emacs30;

in
# emacsWithPackagesFromUsePackage {

# }

(emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
  (exwm.overrideDerivation (o: {
    # https://github.com/ch11ng/exwm/issues/759
#     postInstall = ''
#       cd $out/share/emacs/site-lisp/elpa/exwm-${o.version}
#       sed -i '/(cl-pushnew xcb:Atom:_NET_WM_STATE_HIDDEN exwm--ewmh-state)/d' exwm-layout.el
#       rm exwm-layout.elc
#     '';
  }))
  xelb

  i3bar
  exwm-modeline
  vertico-posframe

  eat
  vterm
  vterm-toggle

  ace-window
  all-the-icons
  buffer-move
  cape
  cl-lib
  cmake-mode
  color-theme-sanityinc-tomorrow
  consult
  consult-project-extra
  corfu
  dape
  dockerfile-mode
  dumb-jump
  eglot-fsharp
  envrc
  exec-path-from-shell
  format-all
  fsharp-mode
  geiser
  geiser-guile
  go-mode
  google-c-style
  gptel
  hcl-mode
  highlight-indentation
  impatient-mode
  jinja2-mode
  jinx
  json-mode
  jupyter
  kubel
  magit
  marginalia
  markdown-preview-mode
  mu4e
  multiple-cursors
  nginx-mode
  nix-mode
  orderless
  pdf-tools
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
  vertico
  vundo
  web-mode
  which-key
  yaml-mode
])
