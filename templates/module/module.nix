{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.module;
in
{
  options.services.module = {
    domain = mkOption {
      type = with types; uniq string;
      description = "";
    };
  };

  config = {
  };
}
