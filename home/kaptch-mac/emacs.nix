{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacsMacport;
    extraPackages = epkgs: with epkgs; [
      use-package
      pdf-tools
      org-pdftools
      agda2-mode
    ];
  };

  home.file.".emacs.d/init.el".source = ./dotfiles/init.el;
}
