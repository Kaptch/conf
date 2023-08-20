{
  description = "Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      coq = pkgs.coq_8_16;
      ocamlPkgs = coq.ocamlPackages;
      coqPkgs = pkgs.coqPackages_8_16;
      deps = [
        coqPkgs.stdpp
        coqPkgs.iris
      ];
    in {
      packages = {
        coq-artifact = coqPkgs.mkCoqDerivation {
          pname = "coq-artifact";
          version = null;
          src = ./src;
          buildPhase = "make";
          propagatedBuildInputs = deps;
        };
      };
      devShell = pkgs.mkShell {
        buildInputs =
          [
            coq
          ] ++ deps;
      };
    });
}
