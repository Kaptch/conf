# https://smallstep.com/blog/build-a-tiny-ca-with-raspberry-pi-yubikey/
{ pkgs, lib, ... }:
{
  services.step-ca = {
    enable = true;
    package = pkgs.step-ca;
    address = "127.0.0.1";
    port = 8448;
    openFirewall = true;
    intermediatePasswordFile = "/run/step-ca/pass";
    settings = null;
  };

  systemd.services.step-ca-pass = {
    description = "step-ca - Key Generator";
    wantedBy = [ "step-ca.service" ];
    requiredBy = [ "step-ca.service" ];
    before = [ "step-ca.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -e
      mkdir -p --mode 0755 /run/step-ca
      if [ ! -f /run/step-ca/pass ]; then
        (set -e; umask 077; < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16 > /run/step-ca/pass)
      fi
    '';
  };
}
