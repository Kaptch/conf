{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            lib = nixpkgs.lib;
            agda = pkgs.agda.withPackages [
              # pkgs.agdaPackages.
            ];
        in
          {
            devShell = pkgs.mkShell {
              buildInputs =
                [
                  agda
                ];
            };
          }
      );
}
