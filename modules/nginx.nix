{ pkgs, lib, ... }:
{
  security.pam.services.nginx.setEnvironment = false;
  systemd.services.nginx.serviceConfig = {
    SupplementaryGroups = [ "shadow" ];
    NoNewPrivileges = lib.mkForce false;
    PrivateDevices = lib.mkForce false;
    ProtectHostname = lib.mkForce false;
    ProtectKernelTunables = lib.mkForce false;
    ProtectKernelModules = lib.mkForce false;
    RestrictAddressFamilies = lib.mkForce [ ];
    LockPersonality = lib.mkForce false;
    MemoryDenyWriteExecute = lib.mkForce false;
    RestrictRealtime = lib.mkForce false;
    RestrictSUIDSGID = lib.mkForce false;
    SystemCallArchitectures = lib.mkForce "";
    ProtectClock = lib.mkForce false;
    ProtectKernelLogs = lib.mkForce false;
    RestrictNamespaces = lib.mkForce false;
    SystemCallFilter = lib.mkForce "";
  };

  services.nginx = {
    enable = true;

    additionalModules = [ pkgs.nginxModules.pam ];

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    # virtualHosts = {
    #   test = {
    #     serverName = "testwww.dom1.dom2.net";
    #     serverAliases = ["testwww.dom2.net"];
    
    virtualHosts = {
      "_" = {
        root = pkgs.writeTextDir "html/index.html" ''
            <html>
              <body>
                <h1>This is a hermetic NixOS configuration!</h1>
              </body>
            </html>
          '';
      };
    };
  };
}
