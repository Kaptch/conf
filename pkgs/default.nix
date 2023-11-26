{ inputs }:
final: prev: with prev;
  {
    hello = callPackage ./hello/default.nix { inherit inputs; };
    xwaylandvideobridge = qt5.callPackage ./xwaylandvideobridge/default.nix { inherit inputs; };
  }
