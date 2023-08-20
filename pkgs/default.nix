{ inputs }:
final: prev: with prev;
  {
    hello = callPackage ./hello/default.nix { inherit inputs; };
  }
