{ inputs }:
final: prev: {
  viu = prev.viu.overrideAttrs (old: {
    version = "1.4.0+overlay";
    cargoBuildFlags = old.cargoBuildFlags or [ ] ++ [ "--features=sixel" ];
    buildInputs = old.buildInputs or [ ] ++ [ prev.libsixel ];
  });
}
