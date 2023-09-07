{ inputs }:
final: prev: {
  cozy = prev.cozy.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ../patches/cozy.diff ];
  });
}
