{ config, pkgs, lib, ... }:
{
  imports = [
  ];

  nix = {
    package = pkgs.nixFlakes;
    settings.auto-optimise-store = true;
    extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.sandbox = true;
  };

  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "pine64-pinephone-firmware"
    ];
  };

  documentation.nixos.enable = false;

  hardware.firmware = [ config.mobile.device.firmware ];

  mobile.beautification = {
    silentBoot = lib.mkDefault true;
    splash = lib.mkDefault true;
  };

  security.sudo = {
    enable = true;
  };

  services.openssh.enable = true;
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    jq
    screen
    usbutils
    unzip
    wget
    whois
    vim
  ];

  environment.etc."machine-info".text = ''
    CHASSIS="handset"
  '';

  services.ntp.enable = true;
  users.users.ntp.group = "ntp";
  users.groups.ntp = {};

  networking.firewall = {
    package = pkgs.iptables-legacy;
  };
  networking.hostName = "pinephone";
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.sit0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  powerManagement.enable = true;

  time.timeZone = "Europe/Copenhagen";

  users.users.kaptch = {
    isNormalUser = true;
    initialPassword = "1234";
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "video"
      "feedbackd"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHMOdDgdR0NMDIrONEqDf3PM9u9O0kU1hk04zxxKYQq7 kaptch@laptop"
    ];
  };

  system.stateVersion = "23.11";
}
