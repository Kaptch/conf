{ config, pkgs, lib, ... }:
{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
    force_turbo=1
  '';
  boot.kernelParams = [ "cma=320M" "console=tty0" ];
  boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
  # boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  sdImage.compressImage = false;
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  # boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "uas" "usb_storage" "ahci" ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_rpi3;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  # boot.loader.raspberryPi.enable = true;

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  imports = [
    ../../modules/sshd.nix
  ];

  users.users.kaptch = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHMOdDgdR0NMDIrONEqDf3PM9u9O0kU1hk04zxxKYQq7 kaptch@laptop"
      ];
  };

  users.users.storage = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvFHph/ja3KZ+ON7kYxpBkixL7rOi9y0zmjnQVoRUA/za6cN2O6lbJOT8aTCs5Vt1uebWziBMlMYUKVX7T7OIoLlskKExbvWGq8ZhmukI6baV6Zdv1BPh3zbwg5QC3XoKYKz5bRuHZYnBjB1tqj5HCWHLupjp/kX4T+CiWUlmm5nieO+IVfY1dlu9I/3UEmyNcTQQzdlwc8Jc6IlAb5uMnkO7yBZ5TOYG23F0Zuy+TsUgOGsknTOZ1dyD/+GZW6DDgxff+ncOLkS6wIlobLE4DazJLLySN3ZKDouClM0f8IIEosV2zpDgU5T9JVKrNETS/RgkC08BVy50JlnpXGLtPiZWAjjtcrQNMYbfZRPlJ4Zcxf1WE2Gd+U4l08XSYm/6Uqf4wa+FCGweB/vHG2Fn3QAUd2GQ/KQFlS/83ukKxwfibh/A3pMkkTNMfJRyHQMtOnmNQyx6FvUOQkCzylNtl8N8y2ts4qaHH14ymOuwpSikwVQNCdg7Osp3QONvJqa8= root@server"
    ];
    packages = with pkgs; [
      borgbackup
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix = {
    package = pkgs.nixFlakes;
    settings.trusted-users = [ "@wheel" ];
    extraOptions = ''experimental-features = nix-command flakes'';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    wpa_supplicant
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.8.0.5/32" ];
      listenPort = 51820;
      generatePrivateKeyFile = true;
      privateKeyFile = "/run/wireguard/pk";
      peers = [
        {
          publicKey = "EpO+SkxY1E3rw7kBE78vhK46YkOwigOzC7mUBJzcLDI=";
          allowedIPs = [
            "10.8.0.0/24"
            # "0.0.0.0/0"
          ];
          endpoint = "46.226.104.75:51800";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  networking.firewall.enable = false;

  networking = {
    interfaces.wlan0 = {
      useDHCP = true;
    };
    interfaces.eth0 = {
      useDHCP = true;
    };
    networkmanager.enable = true;

    hostName = lib.mkOverride 98 "home-rpi";
  };

  # services.mpd = {
  #   enable = true;
  #   musicDirectory = "/var/music";
  # };

  # # http://localhost:6680/iris/
  # services.mopidy = {
  #   enable = true;
  #   extensionPackages = [
  #     pkgs.mopidy-local
  #     pkgs.mopidy-mpd
  #     pkgs.mopidy-iris
  #   ];
  #   configuration = "
  #     [local]
  #     media_dir = /var/music

  #     [mpd]
  #     enabled = true
  #     hostname = 0.0.0.0
  #     port = 6600

  #     [http]
  #     enabled = true
  #     hostname = 0.0.0.0
  #     port = 6680

  #     [iris]
  #     country = GB
  #     locale = en_GB
  #   ";
  # };

  # systemd.tmpfiles.rules = [
  #   "d /var/music 0755 mpd mpd"
  # ];

  system.stateVersion = "23.05";
}
