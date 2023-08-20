{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ../../modules/sshd.nix
    ../../modules/minecraft.nix
  ];

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-label/ESP";
  #     fsType = "ext4";
  #   };

  # fileSystems."/" =
  #   { device = "/dev/disk/by-label/root";
  #     fsType = "ext4";
  #   };

  # swapDevices = [ ];

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
      tmux
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
}
