{ config, lib, pkgs, ... }:
let
  greetd-cfg = config.services.greetd;
  greetd-tty = "tty${toString greetd-cfg.vt}";
in
  {
    imports =
      [
        ./system76-galago.nix
        ./users.nix
      ];

      boot.extraModulePackages = with config.boot.kernelPackages;
      [ v4l2loopback.out ];

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      boot.kernelModules = [ "v4l2loopback" "msr" "snd_aloop" ];

      boot.extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
      '';

      nix = {
        settings.allowed-users = [ "@wheel" ];
        settings.substituters = [
          "https://nix-community.cachix.org"
          "https://insane.cachix.org"
          "https://cachix.cachix.org"
          "https://colmena.cachix.org"
          ];
          settings.trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "insane.cachix.org-1:cLCCoYQKkmEb/M88UIssfg2FiSDUL4PUjYj9tdo4P8o="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
            "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
          ];
          package = pkgs.nixFlakes;
          nixPath = [ "nixpkgs=${pkgs.outPath}" "unstable=${pkgs.unstableOutPath}" ];
          settings.auto-optimise-store = true;
          extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
          "experimental-features = nix-command flakes";
          gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };

      networking.hostName = "laptop";
      networking.networkmanager.enable = true;
      networking.useDHCP = false;
      networking.interfaces.enp36s0.useDHCP = true;
      networking.interfaces.wlp0s20f3.useDHCP = true;

      networking.firewall = {
        package = pkgs.iptables-legacy;
        logReversePathDrops = true;
        # allowedTCPPorts = [ 1701 9001 ];
        checkReversePath = "loose";
        # extraCommands = ''
        # ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51800 -j RETURN
        # ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51800 -j RETURN
        # '';
        # extraStopCommands = ''
        # ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51800 -j RETURN || true
        # ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51800 -j RETURN || true
        # '';
      };

      services.thermald.enable = true;

      services.udisks2.enable = true;

      containers.punchbox = {
        autoStart = false;
        ephemeral = true;
        extraFlags = [ "-U" ];

        config = { config, pkgs, ... }: {
          system.stateVersion = "23.05";

          environment.systemPackages = with pkgs; [ openssh coreutils nftables ];

          users.users.bob = {
            isNormalUser  = true;
            password = "alice";
            shell = "${pkgs.coreutils}/bin/true";
          };

          services.openssh = {
            enable = true;
            ports = [20022];
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = true;
            };
            extraConfig = "
        AllowUsers bob
        Match User bob
        PermitOpen 127.0.0.1:20222
        X11Forwarding no
        AllowAgentForwarding no
        ForceCommand ${pkgs.coreutils}/bin/false
        ";
          };

          services.tor = {
            enable = true;
            torsocks.allowInbound = true;
            enableGeoIP = false;
            relay.onionServices = {
              punchbox = {
                version = 3;
                map = [{
                  port = 20022;
                  target = {
                    addr = "localhost";
                    port = 20022;
                  };
                }];
              };
            };
          };
        };
      };

      services.avahi = {
        nssmdns = true;
        enable = true;
        ipv4 = true;
        ipv6 = true;
      };

      services.upower = {
        enable = true;
      };

      services.logind = {
        extraConfig = ''HandlePowerKey=ignore'';
        lidSwitch = "hybrid-sleep";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "suspend";
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --cmd Hyprland";
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --cmd sway";
            user = "kaptch";
          };
        };
      };

      systemd.services.greetd = {
        unitConfig = {
          After = [
            "multi-user.target"
            "systemd-user-sessions.service"
            "plymouth-quit-wait.service"
            "getty@${greetd-tty}.service"
          ];
        };
      };

      time.timeZone = "Europe/Copenhagen";

      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      fonts.fonts = with pkgs; [
        jetbrains-mono
        font-awesome
      ];

      nixpkgs.config.allowUnfree = true;

      programs.sway.enable = true;
      # programs.hyprland.enable = true;

      programs.nix-ld.enable = true;

      hardware.bluetooth.enable = true;
      hardware.xpadneo.enable = true;
      services.blueman.enable = true;

      services.flatpak.enable = true;

      # comment to use hyprland
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
      };

      hardware.ledger.enable = true;
      services.udev.extraRules = ''
  KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2c97"
  '';

      services.udev.packages = [ pkgs.yubikey-personalization pkgs.via ];

      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      hardware = {
        opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
          extraPackages = with pkgs; [
            mesa.drivers
            intel-media-driver
            vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
          ];
        };
      };

      security.pam.services.swaylock.text = ''
    # Account management.
    account required pam_unix.so

    # Authentication management.
    auth sufficient pam_unix.so   likeauth try_first_pass
    auth required pam_deny.so

    # Password management.
    password sufficient pam_unix.so nullok sha512

    # Session management.
    session required pam_env.so conffile=/etc/pam/environment readenv=0
    session required pam_unix.so
  '';

      security.pam.yubico = {
        enable = true;
        debug = false;
        mode = "challenge-response";
      };

      services.pcscd.enable = true;

      services.printing.enable = true;
      services.printing.browsing = true;
      services.printing.cups-pdf.enable = true;

      virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;
        waydroid.enable = true;
        lxd.enable = true;
        virtualbox = {
          host.enable = true;
          # host.enableExtensionPack = true;
        };
      };

      systemd.services.waydroid-container.enable = true;

      environment.systemPackages = with pkgs; [ git vim ];

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.05"; # Did you read the comment?

  }
