{config, lib, ...}:
{
  virtualisation.qemu.guestAgent.enable = true;
  virtualisation.qemu.options = [
    "-enable-kvm -m 4G"
  ];
  virtualisation.forwardPorts = [
    # # wg
    # { from = "host"; host.port = 51800; guest.port = 51800; }
    # # headscale
    # { from = "host"; host.port = 8080; guest.port = 8080; }
    # # ntfy-sh
    # { from = "host"; host.port = 8090; guest.port = 8090; }
    # # vmess
    # { from = "host"; host.port = 8888; guest.port = 8888; }
    # # shadowsocks
    # { from = "host"; host.port = 5008; guest.port = 5008; }
    # # photoprism
    # { from = "host"; host.port = 2342; guest.port = 2342; }

    # ssh
    { from = "host"; host.port = 2000; guest.port = 22; }
    # nginx
    { from = "host"; host.port = 8000; guest.port = 80; }
    # minecraft
    { from = "host"; host.port = 25565; guest.port = 25565; }
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.getty.autologinUser = "kaptch";
}
