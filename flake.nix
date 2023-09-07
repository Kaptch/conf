{
  description = "Kaptch's NixOS configurations";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://insane.cachix.org"
      "https://cachix.cachix.org"
      "https://colmena.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "insane.cachix.org-1:cLCCoYQKkmEb/M88UIssfg2FiSDUL4PUjYj9tdo4P8o="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
    ];
  };

  inputs = {
    master.url = "github:NixOS/nixpkgs/master";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:rycee/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    headscale = {
      url = "github:juanfont/headscale";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };
    matrix-conduit = {
      url = "gitlab:famedly/conduit";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
        crane.follows = "crane";
      };
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nur.url = "github:nix-community/NUR";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    packwiz2nix = {
      url = "github:getchoo/packwiz2nix";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    statix = {
      url = "github:nerdypepper/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    mobile-nixos = {
      url = "github:NixOS/mobile-nixos/56fc9f9619f305f0865354975a98d22410eed127";
      flake = false;
    };
    nixpkgs-mobile = {
      url = "github:NixOS/nixpkgs/41c7605718399dcfa53dd7083793b6ae3bc969ff";
    };
  };

  outputs = inputs @ { self, ... }:
    let
      local = {
        lib = import ./lib { inherit inputs; } // inputs.nixpkgs.lib // inputs.home-manager.lib;
        overlays = import ./overlays { inherit inputs; };
        pkgs = import ./pkgs { inherit inputs; };
      };
      import-branches = system: final: prev: {
        unstable = import inputs.unstable {
          inherit system;
        };
        master = import inputs.master {
          inherit system;
        };
      };
      import-pkgs = system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
            "discord"
            "minecraft-server"
            "spotify"
            "spotify-unwrapped"
            "steam-original"
            "steam-runtime"
            "steam-run"
            "steam"
            "zoom"
            "vscode-extension-github-codespaces"
            "vscode-extension-ms-vsliveshare-vsliveshare"
          ];
          overlays = [
            # unstable.*
            # master.*
            (import-branches system)
            # unqualified
            inputs.nur.overlay
            inputs.nix-minecraft.overlay
            local.pkgs
          ] ++ local.overlays;
        } // {
          outPath = inputs.nixpkgs.outPath;
          unstableOutPath = inputs.unstable.outPath;
        };
      pin-flake-reg = system: with inputs; {
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
        nix.registry.unstable.flake = inputs.unstable;
        nix.registry.master.flake = inputs.master;
        nix.registry.nur.flake = inputs.nur;
        nix.registry.local.flake = self;
      };
      server_base = {
        system = "x86_64-linux";
        modules = [
          (pin-flake-reg "x86_64-linux")
          inputs.disko.nixosModules.disko
          inputs.nix-minecraft.nixosModules.minecraft-servers
          inputs.agenix.nixosModules.default
          inputs.nur.nixosModules.nur
          inputs.impermanence.nixosModules.impermanence
          inputs.extra-container.nixosModules.default
        ];
      };
    in
      {
        diskoConfigurations = {
          simple = import ./disks/simple.nix;
          luks = import ./disks/luks.nix;
        };

        nixosConfigurations = {
          laptop = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            pkgs = (import-pkgs "x86_64-linux");
            specialArgs = { inherit inputs; };
            modules = [
              (pin-flake-reg "x86_64-linux")
              inputs.nixos-hardware.nixosModules.system76
              inputs.nur.nixosModules.nur
              inputs.impermanence.nixosModules.impermanence
              inputs.nix-ld.nixosModules.nix-ld
              inputs.extra-container.nixosModules.default
              ./systems/laptop-linux/configuration.nix
            ];
          };
          server = inputs.nixpkgs.lib.nixosSystem {
            inherit (server_base);
            system = server_base.system;
            pkgs = (import-pkgs server_base.system);
            specialArgs = { inherit inputs; };
            modules = [
              ./systems/gateway-server/configuration.nix
              ({modulesPath, ... }: {
                imports = server_base.modules;
              })
              # ./disks/simple.nix
              # {
              #   _module.args.disks = "/dev/sda";
              #   boot.loader.grub = {
              #     efiSupport = true;
              #     efiInstallAsRemovable = true;
              #   };
              # }
            ];
          };
          minecraft-server = inputs.nixpkgs.lib.nixosSystem {
            inherit (server_base);
            system = server_base.system;
            pkgs = (import-pkgs server_base.system);
            specialArgs = { inherit inputs; };
            modules = [
              ./systems/minecraft-server/configuration.nix
              ({modulesPath, ... }: {
                imports = server_base.modules;
              })
              (inputs.nixpkgs + "/nixos/modules/virtualisation/openstack-config.nix")
              {
                boot.loader.grub.device = local.lib.mkForce "/dev/xvda";
              }
            ];
          };
          phone-cross = inputs.nixpkgs-mobile.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              (import "${inputs.mobile-nixos}/lib/configuration.nix" {
                device = "pine64-pinephone";
              })
              ./systems/phone-cross/configuration.nix
            ];
          };
        };

        homeManagerConfigurations = {
          "kaptch@laptop" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = (import-pkgs "x86_64-linux");
            extraSpecialArgs = { inherit inputs; };
            modules = [
              inputs.hyprland.homeManagerModules.default
              inputs.nur.nixosModules.nur
              ./home/kaptch/configuration.nix
              {
                home = {
                  username = "kaptch";
                  homeDirectory = "/home/kaptch";
                  stateVersion = "23.05";
                };
              }
            ];
          };
          "sergeistepanenko@mac" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = (import-pkgs "x86_64-darwin");
            modules = [
              ./home/kaptch-mac/configuration.nix
              {
                home = {
                  username = "sergeistepanenko";
                  homeDirectory = "/Users/sergeistepanenko";
                  stateVersion = "23.05";
                };
              }
            ];
          };
        };

        darwinConfigurations."Sergeis-MBP" = inputs.darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          inherit inputs;
          pkgs = (import-pkgs "x86_64-darwin");
          modules = [
            (pin-flake-reg "x86_64-darwin")
            ./systems/laptop-mac/configuration.nix
          ];
        };

        packages."x86_64-linux" = {
          qemu = inputs.nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            pkgs = (import-pkgs "x86_64-linux");
            specialArgs.inputs = inputs;
            format = "vm";
            modules = [
              ({modulesPath, ... }: {
                imports = server_base.modules ++ [
                  ./systems/gateway-server/configuration.nix
                  ./modules/vm.nix
                ];
              })
            ];
          };

          qemu-minecraft = inputs.nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            pkgs = (import-pkgs "x86_64-linux");
            specialArgs.inputs = inputs;
            format = "vm";
            modules = [
              ({modulesPath, ... }: {
                imports = server_base.modules ++ [
                  ./systems/minecraft-server/configuration.nix
                  ./modules/vm.nix

                ];
              })
            ];
          };

          rpi3 = inputs.nixos-generators.nixosGenerate {
            system = "aarch64-linux";
            pkgs = (import-pkgs "aarch64-linux");
            specialArgs.inputs = inputs;
            format = "sd-aarch64";
            modules = [
              ({modulesPath, ... }: {
                imports = server_base.modules ++ [
                  ./systems/gateway-server/configuration.nix
                  ./systems/rpi3/configuration.nix
                ];
              })
            ];
          };

          install-iso = inputs.nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            pkgs = (import-pkgs "x86_64-linux");
            format = "install-iso";
            modules = [
              ({modulesPath, ... }: {
                imports = [
                  ({pkgs, lib, ...}: {
                    users.users.root.openssh.authorizedKeys.keys = [
                      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Z10i0n2p9SI6zBKN0RMz+2TCgugMMYggE2GJxnauDxzEJQY604qvZiQ1IuI9tKk4905gBMtoBNpCH4jvLLOCdQ15/6gTM15WzFg4O8jJytVpFyOxT7PDni7z4BNlv6jse2lL13XQMv7wZmnQo3bkZEmPxhEokUJi3Xv9ejUXXZw1VIgLtckpRE712NgB3Y9O6l9c4Sn6184uiJ8870kSmt/c5lLY04Mnq7kf8oyFx/t8H7GDaZgnRNJ9J0kcxQcjgJuqyVtysXo4KJx10blWOcjDHXZ8BEziwZHR8wRlkY6qi++Cw8abcCoyMJ7hxXiLB3zP2B0kauLmmpcblCNJDLuFeRDRMwK7OoAfNArWiudELVCv+n8whf+CqMkX1ZegL+Z7XPUi3s1KKbbBtuWiNqRpFFQgtr1lg2ij6eJYJaaXnL17i3Z3sd36hObkakM0Q+FBdJhoGrH/1RAlSA/mg9FqisQrjWIc0lay9UPkjMxStuFStQoyJdEULdQVVl9McR1jAv0CTGf18tCUzZ+zc/vuPxzsecDh/ueARrkV58MAhs9hLMCCHOjB7fG8l14xeBL8bEwLKgR7B6OUhL70QRpf5WSFySAB29drdcJLgm9QKGuhZkHn5sDMLkD3UoDwXaZ/YK1Pm+evtyKuVwl/RXPLKJKa9LkZ5sC7qUXsLw== openpgp:0xC1292CEE"
                    ];
                    environment.systemPackages = with pkgs; [
                      git
                      vim
                      inputs.agenix.packages."${system}".default
                      inputs.statix.packages."${system}".statix
                      inputs.comma.packages."${system}".default
                      inputs.disko.packages."${system}".default
                      inputs.anywhere.packages."${system}".default
                    ];
                  })
                ];
              })
            ];
          };

          modpack = inputs.packwiz2nix.lib.mkMultiMCPack {
            pkgs = (import-pkgs "x86_64-linux");
            mods = inputs.packwiz2nix.lib.mkPackwizPackages (import-pkgs "x86_64-linux") ./misc/minecraft-mods-simple/checksums.json;
            name = "modpack";
          };
        };

        templates = {
          module = {
            path = ./templates/module;
          };
          overlay = {
            path = ./templates/overlay;
          };
          pkg = {
            path = ./templates/pkg;
          };
          agda = {
            path = ./templates/agda;
          };
          coq = {
            path = ./templates/coq;
          };
          latex-presentation = {
            path = ./templates/latex-presentation;
          };
          latex-report = {
            path = ./templates/latex-report;
          };
          c = {
            path = ./templates/c;
          };
          haskell = {
            path = ./templates/haskell;
          };
          ocaml = {
            path = ./templates/ocaml;
          };
          python = {
            path = ./templates/python;
          };
          rust = {
            path = ./templates/rust;
          };
        };

        apps."x86_64-linux" = {
          generate-checksums = inputs.packwiz2nix.lib.mkChecksumsApp (import-pkgs "x86_64-linux") ./misc/minecraft-mods/mods;
        };

        devShells."x86_64-linux".default = (import-pkgs "x86_64-linux").mkShell {
          pkgs = (import-pkgs "x86_64-linux");
          buildInputs = with (import-pkgs "x86_64-linux");
            [
              vim
              git
              wireguard-tools
              packwiz
              inputs.agenix.packages."${system}".default
              inputs.statix.packages."${system}".statix
              inputs.comma.packages."${system}".default
              inputs.disko.packages."${system}".default
              inputs.anywhere.packages."${system}".default
            ];
        };
      };
}
