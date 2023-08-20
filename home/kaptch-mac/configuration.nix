{ config, lib, pkgs, ... }:

let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full
    gentium-tug
    pbox
    scalerel
    dashbox
    xifthen
    ifmtarg
    biblatex
    cleveref
    biber
    iftex
    xstring
    totpages
    environ;
  });

  agda = pkgs.agda.withPackages [ pkgs.agdaPackages.standard-library pkgs.agdaPackages.agda-categories pkgs.agdaPackages.cubical ];
  ncoq = pkgs.coq_8_16;
  ncoqPackages = pkgs.coqPackages_8_16;
in
  {
    imports =
      [
        ./git.nix
        ./emacs.nix
        ./services.nix
        ./zathura.nix
        ./vim.nix
      ];

      programs.kitty = {
        enable = true;
        theme = "Space Gray Eighties";
      };

      programs.tmux = {
        enable = true;
        clock24 = true;
        terminal = "kitty";
      };

      programs.zsh = {
        enable = true;
        enableSyntaxHighlighting = true; 
        sessionVariables = { 
          EDITOR = "vim";
          TERMINAL = "kitty";
          COQPATH = "/home/kaptch/.nix-profile/lib/coq/8.16/user-contrib";
        };
      shellAliases = {
        emacs = "${pkgs.emacsMacport}/Applications/Emacs.app/Contents/MacOS/Emacs";
      };
    };   

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        github.codespaces
        github.copilot
        matklad.rust-analyzer
        mkhl.direnv
        kahole.magit
        bungcip.better-toml
        ocamllabs.ocaml-platform
        james-yu.latex-workshop
        dracula-theme.theme-dracula
      ];
    }; 

    programs.home-manager.enable = true;

    programs.zathura = {
      enable = true;
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    home.activation = {
      copyApplications =
        let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          baseDir="$HOME/Applications/Home Manager Apps"
          if [ -d "$baseDir" ]; then
          rm -rf "$baseDir"
          fi
          mkdir -p "$baseDir"
          for appFile in ${apps}/Applications/*; do
          target="$baseDir/$(basename "$appFile")"
          $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
          $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
          done
        '';
      };  

      nixpkgs.config.allowUnfreePredicate = 
      pkg: builtins.elem (lib.getName pkg) [ "vscode-extension-github-codespaces"
      "vscode-extension-github-copilot"
    ];

    home.packages = with pkgs; [
      agda
      ncoqPackages.autosubst
      ncoqPackages.mathcomp-ssreflect
      ncoqPackages.equations
      ncoqPackages.category-theory
      ncoqPackages.metacoq
      ncoqPackages.metacoq-pcuic
      ncoqPackages.serapi
      ncoqPackages.iris
      ncoqPackages.stdpp
      delta
      direnv
      emacs-all-the-icons-fonts
      firefox-bin
      font-awesome
      gh
      gnumake
      hicolor-icon-theme
      ispell
      ncoq
      ocamlPackages.ocaml-lsp
      pinentry-emacs
      tex
      ltex-ls
      unzip
      vim
      wget
      xz
    ];
  }
