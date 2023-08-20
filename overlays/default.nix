{ inputs }:
let
  overlays = [
    (import ./viu.nix { inherit inputs; })
    (import ./waybar.nix { inherit inputs; })
    (import ./pmbootstrap.nix { inherit inputs; })
  ];

in overlays
