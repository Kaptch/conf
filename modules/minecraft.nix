{ inputs, pkgs, lib, ... }:
let
  inherit (inputs.packwiz2nix.lib) mkPackwizPackages mkModLinks;
  mods-simple = mkPackwizPackages pkgs ../misc/minecraft-mods-simple/checksums.json;
  mods-custom = mkPackwizPackages pkgs ../misc/minecraft-mods-custom/checksums.json;
  mods = pkgs.fetchPackwizModpack {
    url = "https://git.sr.ht/~jubbidejubbidie/minecraft-mods/blob/main/pack.toml";
    packHash = "sha256-gWbXwhK9EROD+3V3W/Mg1A5kQO75JYtqzlvpRTCpJK4=";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.test1 = {
      enable = false;
      package = pkgs.fabricServers.fabric-1_19_2;
      openFirewall = true;
      serverProperties = {
        motd = "NixOS Minecraft server!";
        online-mode = false;
      };
      jvmOpts = "-Xmx4G -Xms2G";
      symlinks = mkModLinks mods-simple;
    };

    servers.test2 = {
      enable = false;
      package = pkgs.fabricServers.fabric-1_19_2;
      openFirewall = true;
      serverProperties = {
        motd = "NixOS Minecraft server!";
        online-mode = false;
      };
      jvmOpts = "-Xmx4G -Xms2G";
      symlinks = {
        "mods" = "${mods}/mods";
      };
    };

    servers.test3 = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_19_2;
      openFirewall = true;
      serverProperties = {
        motd = "server?";
        online-mode = false;
      };
      jvmOpts = "-Xmx4G -Xms2G";
      symlinks = mkModLinks mods-custom;
    };
  };
}
