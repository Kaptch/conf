{ config, pkgs, lib, ... }:
{
  boot.loader.grub.enable = false;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "uas" "usb_storage" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["cma=256M"];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
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
      ips = [ "10.8.0.4/32" ];
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
      # useDHCP = false;
      # ipv4.addresses = [{
      #   address = "192.168.1.115";
      #   prefixLength = 24;
      # }];
    };
    interfaces.eth0 = {
      useDHCP = true;
    };
    # wireless.enable = true;
    # wireless.interfaces = [ "wlan0" ];
    networkmanager.enable = true;

    hostName = lib.mkOverride 98 "home-rpi";
  };
}
