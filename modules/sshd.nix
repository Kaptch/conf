{ pkgs, lib, ... }:
{
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = lib.mkOverride 98 "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };
}
