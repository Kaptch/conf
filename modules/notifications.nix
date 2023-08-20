{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.notifications;
in
{
  options.services.notifications = {
    enable = mkOption {
      default = false;
      type = with types; bool;
    };
    domain = mkOption {
      type = with types; uniq string;
      description = "Domain name";
    };
  };

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":8090";
      };
    };

    services.nginx = {
      virtualHosts = {
        "notify.${cfg.domain}" = {
          locations."/" = {
            proxyPass =
              "http://localhost:8090";
            proxyWebsockets = true;
            extraConfig = ''
            auth_pam "Password Required";
            auth_pam_service_name "nginx";
          '';
          };
        };
      };
    };
  };
}
