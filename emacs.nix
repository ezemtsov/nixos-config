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
      src = pkgs.fetchFromGitHub {
        owner = "zevlg";
        repo = "telega.el";
        rev = "f5b48d2a605c1383ddb8522ed315b625115f16a6";
        hash = "sha256-ebaM9Wl9uoBOAVDGwKxYFzpUk8JGtM4DA0ML/vGWBIo=";
      };
      buildInputs = [ pkgs.tdlib ];
    };
  };
}
