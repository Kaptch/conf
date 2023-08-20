{ inputs, lib, config, pkgs, ... }:
let
  domain = "localhost";
in
{
  imports = [
    ../../modules/nginx.nix
    ../../modules/notifications.nix
    ../../modules/sshd.nix
    ../../modules/mosquitto.nix
  ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/ESP";
      fsType = "ext4";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  swapDevices = [ ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    settings.trusted-users = [ "@wheel" ];
    extraOptions = ''experimental-features = nix-command flakes'';
  };

  environment.systemPackages = with pkgs;
    [
      wireguard-tools
    ];

  system.stateVersion = "23.05";

  users.users = {
    kaptch = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHMOdDgdR0NMDIrONEqDf3PM9u9O0kU1hk04zxxKYQq7 kaptch@laptop"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "server";

  networking.firewall.enable = false;

  # services.notifications = {
  #   domain = "localhost";
  # };

  # https://hydra.nixos.org/build/144800223/download/2/nixos/index.html#module-services-sourcehut
  # services.sourcehut = {
  #   enable = true;
  #   originBase = "sr.ht.local";
  #   services = [
  #     "builds"
  #     "git"
  #     "hub"
  #     "man"
  #     "meta"
  #   ];
  #   builds = {
  #     enableWorker = true;
  #   };
  #   settings = {
  #     "sr.ht" = {
  #       environment = "production";
  #       global-domain = "sr.ht.local";
  #       origin = "http://sr.ht.local";
  #       # nix shell nixpkgs#sourcehut.coresrht -c srht-keygen network
  #       network-key = "OeXzQ6A8Vcgt5QJkXScuxeXCtfdKzKev99BRNb3_CWQ=";
  #       # nix shell nixpkgs#sourcehut.coresrht -c srht-keygen service
  #       service-key = "62427596fed00fa48c19f95bc85c14d0c618a5f8c130b53ba9a6a6b403bf1507";
  #     };
  #     # nix shell nixpkgs#sourcehut.metasrht -c metasrht-manageuser -t admin -e mymail@gmail.com misuzu
  #     "meta.sr.ht" = {
  #       origin = "http://meta.sr.ht.local";
  #     };
  #     "builds.sr.ht" = {
  #       origin = "http://builds.sr.ht.local";
  #       oauth-client-secret = "8f5fc39b5948907e62c737f6b48462dc";
  #       oauth-client-id = "299db9f9c2013170";
  #     };
  #     "meta.sr.ht::settings" = {
  #       onboarding-redirect = "http://meta.sr.ht.local";
  #     };
  #     # nix shell nixpkgs#sourcehut.coresrht -c srht-keygen webhook
  #     webhooks.private-key= "U7yd/8mGs/v0O3kId4jpeSghUCa9tqP1fYQwSV8UOqo=";
  #   };
  # };

  # services.nginx = {
  #   enable = true;
  #   recommendedTlsSettings = true;
  #   recommendedOptimisation = true;
  #   recommendedGzipSettings = true;
  #   recommendedProxySettings = true;

  #   virtualHosts = with pkgs.lib; {
  #     "builds.sr.ht.local".forceSSL = mkForce false;
  #     "git.sr.ht.local".forceSSL = mkForce false;
  #     "hub.sr.ht.local".forceSSL = mkForce false;
  #     "logs.sr.ht.local".forceSSL = mkForce false;
  #     "man.sr.ht.local".forceSSL = mkForce false;
  #     "meta.sr.ht.local".forceSSL = mkForce false;
  #     "sr.ht.local".forceSSL = mkForce false;
  #   };
  # };

  # services.murmur = {
  #   enable = true;
  #   logFile = "/var/log/murmur/murmurd.log";
  #   welcometext = "Mumble";
  #   registerName = "kaptch";
  #   hostName = "kaptch";
  # };

  # services.headscale = {
  #   enable = true;
  #   address = "0.0.0.0";
  #   port = 8080;
  #   settings = {
  #     server_url = "http://localhost";
  #     dns_config.base_domain = "localhost";
  #     logtail.enabled = false;
  #   };
  # };

  # services.ircdHybrid = {
  #   enable = true;
  #   sid = "ffdfhdvcxfer";
  #   serverName = "ghgjitbv";
  # };

  # services.mastodon = {
  #   enable = true;
  #   localDomain = "social.example.com";
  #   configureNginx = true;
  #   smtp.fromAddress = "noreply@social.example.com";
  #   extraConfig.SINGLE_USER_MODE = "true";
  # };

  # services.jitsi-meet = {
  #   enable = true;
  #   hostName = "meet.example.com";
  #   config = {
  #     prejoinPageEnabled = true;
  #     disableModeratorIndicator = true;
  #   };
  #   interfaceConfig = {
  #     SHOW_JITSI_WATERMARK = false;
  #   };
  # };

  # services.jitsi-videobridge.openFirewall = true;

  # services.photoprism = {
  #   enable = true;
  #   originalsPath = "/var/lib/photoprism";
  # };

  # services.v2ray = {
  #   enable = true;
  #   config = {
  #     log.loglevel = "debug";
  #     inbounds = [
  #       {
  #         protocol = "vmess";
  #         port = 8888;
  #         settings = {
  #           clients = [
	#             {
  #               id = "45efdaa4-2233-4cb4-8b31-eb2db00bb58d";
  #             }
	#           ];
  #         };
  #       }
  #       # {
  #       #   protocol = "shadowsocks";
  #       #   port = 1080;
  #       #   settings = {
  #       #     method = "aes-128-cfb";
  #       #     password = "aaaaa";
  #       #     networks = "tcp,udp";
  #       #   };
  #       # }
  #     ];
  #     outbounds = [
  #       {
  #         protocol = "freedom";
  #         settings = {};
  #       }
  #       {
  #         protocol = "loopback";
  #         settings = {
  #           inboundTag = "test";
  #         };
  #       }
  #       # {
  #       #   protocol = "vmess";
  #       #   settings = {
  #       #     vnext = [{
  #       #       address = "175.24.191.112";
  #       #       port = 53;
  #       #       users = [{
  #       #         id = "1e20eca6-8bd8-512d-596f-6067be9f3a17";
  #       #         alterId = 64;
  #       #       }];
  #       #     }];
  #       #   };
  #       #   streamSettings = {
  #       #     network = "mkcp";
  #       #     kcpSettings = {
  #       #       uplinkCapacity = 100;
  #       #       downlinkCapacity = 100;
  #       #       congestion = true;
  #       #       header = { type = "wechat-video"; };
  #       #     };
  #       #   };
  #       # }
  #     ];
  #   };
  # };

  # services.shadowsocks = {
  #   enable = true;
  #   encryptionMethod = "aes-256-cfb";
  #   passwordFile = "/run/shadowsocks/pass";
  #   port = 5008;
  # };

  # systemd.services.shadowsocks-pass = {
  #   description = "Shadowsocks - Key Generator";
  #   wantedBy = [ "shadowsocks-libev.service" ];
  #   requiredBy = [ "shadowsocks-libev.service" ];
  #   before = [ "shadowsocks-libev.service" ];

  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };

  #   script = ''
  #     set -e
  #     # If the parent dir does not already exist, create it.
  #     # Otherwise, does nothing, keeping existing permisions intact.
  #     mkdir -p --mode 0755 /run/shadowsocks
  #     if [ ! -f /run/shadowsocks/pass ]; then
  #        # Write private key file with atomically-correct permissions.
  #       (set -e; umask 077; < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16 > /run/shadowsocks/pass)
  #     fi
  #   '';
  # };

  # owncast
  # authelia
}
