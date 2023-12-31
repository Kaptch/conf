{ pkgs, ... }:
let
  myEmacs = (pkgs.emacs.override {
    withPgtk = true;
  });
in
{
  programs.emacs = {
    enable = true;
    package = myEmacs;
    extraPackages = epkgs: with epkgs; [
      use-package
      pdf-tools
      org-pdftools
      agda2-mode
    ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  home.file.".emacs.d/init.el".source = ./dotfiles/init.el;
}
