{ inputs }:
final: prev: {
  waybar = prev.waybar.overrideAttrs (old: {
    version = "0.9.18+overlay";
    mesonFlags = (old.mesonFlags or  []) ++ [ "-Dexperimental=true" ];
    patches = (old.patches or []) ++ [ ../patches/waybar.diff ];
  });
}
