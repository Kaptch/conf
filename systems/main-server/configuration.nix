{ lib, config, pkgs, ... }:
let
  interfaceName = "enX0";
  admin = "kaptch";
  privatezone = ''
$ORIGIN vpn.
$TTL 1D
@ IN SOA mainserver ${admin} ( 202206107 3h 1h 1w 1d )
mainserver A 10.8.0.1
mainserver AAAA fdc9:281f:04d7:9ee9::1
test A 10.8.0.1
jellyfin A 10.8.0.1
transmission A 10.8.0.1
syncthing A 10.8.0.1
hydra A 10.8.0.1
git A 10.8.0.1
vaultwarden A 10.8.0.1
chat A 10.8.0.1
calendar A 10.8.0.1
'';
  privatefile = pkgs.writeText "private.zone" privatezone;
  configDns = ''
vpn:53 {
  bind wg0
  log
	errors
	acl {
	  allow net 10.8.0.0/24
    block
	}
	file ${privatefile}
}
.:53 {
  bind wg0
  log
	errors
	acl {
	  allow net 10.8.0.0/24
    block
	}
  forward . 127.0.0.1:10053 127.0.0.1:10054 127.0.0.1:10055 {
    except vpn
    policy random
    health_check 5s
	}
	cache 6
}
.:10053 {
  bind lo
	acl {
    allow net 127.0.0.1
    block
  }
  forward . tls://8.8.8.8 tls://8.8.4.4 {
    tls_servername dns.google
	  health_check 5s
  }
}
.:10054 {
  bind lo
	acl {
	  allow net 127.0.0.1
    block
	}
  forward . tls://1.1.1.1 tls://1.0.0.1 {
    tls_servername cloudflare-dns.com
	  health_check 5s
	}
}
.:10055 {
  bind lo
	acl {
	  allow net 127.0.0.1
    block
	}
  forward . tls://9.9.9.9 {
	  tls_servername dns.quad9.net
	  health_check 5s
	}
  cache 30
}
'';
in
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    settings.trusted-users = [ "@wheel" ];
    extraOptions = ''experimental-features = nix-command flakes'';
    # buildMachines = [
    #   { hostName = "localhost";
    #     system = "x86_64-linux";
    #     supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
    #     maxJobs = 8;
    #   }
    # ];
  };

  users.users = {
    kaptch = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
      ];
    };
    git = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
      ];
    };
    nginx = {
      extraGroups  = [ "gitolite" ];
    };
  };

  users.groups.media = {};

  security.sudo.wheelNeedsPassword = false;
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];
  };
  security.sudo.execWheelOnly = true;

  systemd.timers.create-cert = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1h";
      Unit = "create-cert.service";
    };
  };

  systemd.services.create-cert = {
    description = "Create a certificate";
    script = ''
      mkdir -p --mode 0755 /run/ssl
      if [ ! -f /run/ssl/cert.pem ]; then
         cd /run/ssl
         ${pkgs.libressl}/bin/openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj '/CN=localhost'
         chmod 644 cert.pem
         chmod 644 key.pem
         chgrp nginx cert.pem
         chgrp nginx key.pem
      fi
      if [[ $(find "/run/ssl/cert.pem" -mtime +365 -print) ]]; then
         cd /run/ssl
         ${pkgs.libressl}/bin/openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj '/CN=localhost'
         chmod 644 cert.pem
         chmod 640 key.pem
         chgrp nginx cert.pem
         chgrp nginx key.pem
      fi
    '';

    wantedBy = [ "multi-user.target" "nginx.service" ];

    unitConfig = {
      Before = [ "multi-user.target" "nginx.service" ];
    };

    serviceConfig = {
      User = "root";
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  networking.hostName = "server";

  networking.nat = {
    enable = true;
    externalInterface = interfaceName;
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [
      "10.8.0.1/24"
      "fdc9:281f:04d7:9ee9::1/64"
    ];
    generatePrivateKeyFile = true;
    listenPort = 51800;
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ${interfaceName} -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ${interfaceName} -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ${interfaceName} -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ${interfaceName} -j MASQUERADE
    '';
    privateKeyFile = "/run/wireguard/pk";
    peers = [
      {
        publicKey = "ktinZbnoSD9g3Loj1exttzhNYPXKCsOdDw95Mzp9FUI=";
        allowedIPs = [
          "10.8.0.2/32"
          "fdc9:281f:04d7:9ee9::2/128"
        ];
      }
      {
	      publicKey = "mcT2ASibJB8lU5X5s3L37a9+t0BNrZc2pHZljYz+XgM=";
        allowedIPs = [
          "10.8.0.3/32"
          "fdc9:281f:04d7:9ee9::3/128"
        ];
      }
      {
        publicKey = "M85+QT1tvWNfXp7p0PWZROQS/8mJMNBpInvk7JYOxDE=";
        allowedIPs = [
          "10.8.0.4/32"
          "fdc9:281f:04d7:9ee9::4/128"
        ];
      }
    ];
  };

  networking.firewall =
      {
        enable = true;
        allowedTCPPorts = [
          22 # ssh
          53 # dns
          80 # http
          443 # http
          5008 # shadowsocks
          12345 # shadowsocks
        ];

        allowedUDPPorts = [
          53 # dns
          1194 # shadowsocks
          12345 # shadowsocks
          51800 # wireguard
        ];
      };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [
          "localhost:5232"
        ];
      };
      auth = { type = "none"; };
      web = { type = "internal"; };
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    initdbArgs = [ "--data-checksums" ];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/64 trust
      host all all 0.0.0.0/0 reject
    '';
  };

  services.postgresqlBackup = {
    enable = true;
    location = "/var/lib/postgres-backup";
    compression = "none";
  };

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 3011;
      websocketEnabled = true;
    };
  };

  services.borgbackup.jobs."borgbase" = {
    paths = [
      "/home"
    ];
    exclude = [
      "**/target"
      "/home/*/go/bin"
      "/home/*/go/pkg"
    ];
    repo = "ssh://storage@10.8.0.4:22/./borg";
    encryption.mode = "none";
    environment = { BORG_RSH = "ssh -i /run/ssh/id_borg"; };
    compression = "auto,lzma";
    startAt = "daily";
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
  };

  services.gitweb = {
    gitwebTheme = true;
    projectroot = "${config.services.gitolite.dataDir}/repositories";
  };

  services.gitolite = {
    enable = true;
    user = "git";
    extraGitoliteRc = ''
      $RC{UMASK} = 0027;
    '';
    adminPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE";
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    gitweb = {
      enable = true;
      location = "";
      virtualHost = "git.vpn";
      user = "nginx";
      group = config.services.gitolite.group;
    };

    virtualHosts = {
      "test.vpn" = {
        default = true;
        onlySSL = true;
        sslCertificate = "/run/ssl/cert.pem";
        sslCertificateKey = "/run/ssl/key.pem";
        locations."/" = {
          root = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
        };
      };
      "chat.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        enableACME = false;
        forceSSL = false;
      };
      "calendar.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:5232/";
          extraConfig = ''
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
        locations."/radicale/" = {
          proxyPass = "http://localhost:5232/";
          extraConfig = ''
            proxy_set_header  X-Script-Name /radicale;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
      };
      ${config.services.nginx.gitweb.virtualHost} = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
      };
      "syncthing.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:8384";
	        extraConfig = "allow 10.8.0.0/28;\ndeny all;";
        };
      };
      "jellyfin.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:8096/";
          proxyWebsockets = true;
        };
      };
      "vaultwarden.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:3011/";
          proxyWebsockets = true;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://localhost:3012";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://localhost:3011";
          proxyWebsockets = true;
        };
      };
      "hydra.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:3000/";
          proxyWebsockets = true;
        };
      };
      "transmission.vpn" = {
        listen = [ {
	        addr = "10.8.0.1";
	        port = 80;
		    } ];
        locations."/" = {
          proxyPass = "http://localhost:9091/";
          proxyWebsockets = true;
	        extraConfig = "allow 10.8.0.0/28;\ndeny all;";
        };
      };
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
      "8.8.8.8"
      "84.238.89.37/32"
    ];
  };

  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000";
    debugServer = false;
    listenHost = "localhost";
    logo = null;
    port = 3000;
    minimumDiskFree = 5;
    minimumDiskFreeEvaluator = 2;
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  services.transmission = {
    enable = true;
    group = "media";
    downloadDirPermissions = "775";
    settings = {
      rpc-enabled = true;
      rpc-port = 9091;
      rpc-host-whitelist = "transmission.vpn";
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "localhost:8384";
    extraOptions =  { gui = { insecureSkipHostcheck = true; }; };
    overrideDevices = true;
    overrideFolders = true;
  };

  services.jellyfin = {
    enable = true;
    group = "media";
  };

  services.openssh = {
    enable = true;
    allowSFTP = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = lib.mkOverride 98 "no";
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  services.shadowsocks = {
    enable = true;
    encryptionMethod = "aes-256-cfb";
    passwordFile = "/run/shadowsocks/pass";
    port = 5008;
  };

  services.coredns = {
    enable = true;
    config = configDns;
  };

  systemd.services.shadowsocks-pass = {
    description = "Shadowsocks - Key Generator";
    wantedBy = [ "shadowsocks-libev.service" ];
    requiredBy = [ "shadowsocks-libev.service" ];
    before = [ "shadowsocks-libev.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -e
      # If the parent dir does not already exist, create it.
      # Otherwise, does nothing, keeping existing permisions intact.
      mkdir -p --mode 0755 /run/shadowsocks
      if [ ! -f /run/shadowsocks/pass ]; then
         # Write private key file with atomically-correct permissions.
        (set -e; umask 077; < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16 > /run/shadowsocks/pass)
      fi
    '';
  };

  systemd.services.borg-key = {
    description = "Borg ssh - Key Generator";
    wantedBy = [ "borgbackup-job-borgbase.service" ];
    requiredBy = [ "borgbackup-job-borgbase.service" ];
    before = [ "borgbackup-job-borgbase.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -e
      mkdir -p --mode 0755 /run/ssh
      if [ ! -f /run/ssh/id_borg ]; then
        (set -e; umask 077; ssh-keygen -q -t rsa -N ''' -f /run/ssh/id_borg)
      fi
    '';
  };

  environment.systemPackages = with pkgs;
    [
      wireguard-tools
    ];

  system.stateVersion = "23.05";
}
