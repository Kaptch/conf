{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            lib = nixpkgs.lib;
            python-with-my-packages = pkgs.python3.withPackages (p: with p; [
              
            ]);
        in
          {
            devShell = pkgs.mkShell {
              buildInputs =
                [
                  python-with-my-packages
                ];
            };
          }
      );
}
