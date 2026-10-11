let
  sources = import ./npins;
in
[
  (import sources.emacs-overlay)
]
