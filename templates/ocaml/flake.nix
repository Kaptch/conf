{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        legacyPackages = nixpkgs.legacyPackages.${system};
        ocamlPackages = legacyPackages.ocamlPackages;
        lib = legacyPackages.lib;

        sources = {
          ocaml = nix-filter.lib {
            root = ./.;
            include = [
              ".ocamlformat"
              "dune-project"
              (nix-filter.lib.inDirectory "bin")
              (nix-filter.lib.inDirectory "lib")
              (nix-filter.lib.inDirectory "test")
            ];
          };

          nix = nix-filter.lib {
            root = ./.;
            include = [
              (nix-filter.lib.matchExt "nix")
            ];
          };
        };
      in
        {
          packages = {
            default = self.packages.${system}.nika;

            nika = ocamlPackages.buildDunePackage {
              pname = "template";
              version = "0.1.0";
              duneVersion = "3";
              src = sources.ocaml;

              nativeBuildInputs = [ legacyPackages.pkg-config ];
              
              buildInputs = with ocamlPackages; [
                base
                core
                core_unix
              ];
              
              strictDeps = true;

              preBuild = ''
                dune build template.opam
              '';
            };
          };

          devShells = {
            default = legacyPackages.mkShell {
              packages = [
                legacyPackages.nixpkgs-fmt
                legacyPackages.ocamlformat
                legacyPackages.fswatch
                ocamlPackages.odoc
                ocamlPackages.ocaml-lsp
                ocamlPackages.ocamlformat-rpc-lib
                ocamlPackages.utop
              ];

              inputsFrom = [
                self.packages.${system}.template
              ];
            };
          };

          checks = {
            dune-fmt = legacyPackages.runCommand "check-dune-fmt"
              {
                nativeBuildInputs = [
                  ocamlPackages.dune_3
                  ocamlPackages.ocaml
                  legacyPackages.ocamlformat
                ];
              }
              ''
              echo "checking dune and ocaml formatting"
              dune build \
                --display=short \
                --no-print-directory \
                --root="${sources.ocaml}" \
                --build-dir="$(pwd)/_build" \
                @fmt
              touch $out
            '';

            dune-doc = legacyPackages.runCommand "check-dune-doc"
              {
                ODOC_WARN_ERROR = "true";
                nativeBuildInputs = [
                  ocamlPackages.dune_3
                  ocamlPackages.ocaml
                  ocamlPackages.odoc
                ];
              }
              ''
              echo "checking ocaml documentation"
              dune build \
                --display=short \
                --no-print-directory \
                --root="${sources.ocaml}" \
                --build-dir="$(pwd)/_build" \
                @doc
              touch $out
            '';
          };
        });
}
