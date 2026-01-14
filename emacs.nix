{ pkgs }:

pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs30;
  config = ./dotfiles/emacs/init.el;

  # Additional packages not automatically detected from use-package
  # declarations
  extraEmacsPackages = epkgs: with epkgs; [
    vterm
    jinx
    treesit-grammars.with-all-grammars
  ] ++ (with epkgs.elpaPackages; [
    exwm
    xelb
  ]) ++ (with epkgs.melpaPackages; [
    telega
  ]);

  override = self: super: {
    exwm = super.exwm.overrideDerivation (o: {
      # https://github.com/ch11ng/exwm/issues/759
      postInstall = ''
        cd $out/share/emacs/site-lisp/elpa/exwm-${o.version}
          sed -i '/(cl-pushnew xcb:Atom:_NET_WM_STATE_HIDDEN exwm--ewmh-state)/d' exwm-layout.el
          rm exwm-layout.elc
      '';
    });

    telega = super.telega.overrideAttrs {
      buildInputs = [
        (pkgs.tdlib.overrideAttrs {
          version = "1.8.57";
          src = pkgs.fetchFromGitHub {
            owner = "tdlib";
            repo = "td";
            rev = "6f4ee8703898f7829c442c74c5170beada171962";
            hash = "sha256-G0wy//IkI/hVDeMRdZey1sagShu0bEM9/m9z/t1K/Co=";
          };
        })
      ];
    };
  };
}
