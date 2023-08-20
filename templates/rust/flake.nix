{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, utils, rust-overlay, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rust = pkgs.rust-bin.stable."1.65.0".default.override {
          extensions = [ "rust-src" ];
        };
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rust;
          rustc = rust;
        };
        llvmPkgs = pkgs.llvmPackages_13;
      in
        {
          defaultPackage = rustPlatform.buildRustPackage {
            src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
            doCheck = true;
            pname = "template";
            version = "0.0.1";
            nativeBuildInputs = [  ];
            buildInputs = with pkgs; [

            ];
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };

          defaultApp = utils.lib.mkApp {
            drv = self.defaultPackage."${system}";
          };

          devShell = with pkgs; mkShell {
            nativeBuildInputs = [ pkgs.makeWrapper rustPlatform.bindgenHook ];
            buildInputs = [              
              lldb_13
              rust
              clippy
              rustfmt
              rust-analyzer
            ];
          };
        });
}
