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
  ];

  override = self: super: {
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
