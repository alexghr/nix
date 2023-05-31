{
  description = "Manage my Nix-based machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.nixpkgs-2305.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nixpkgs-2211.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.alexghr-nixpkgs.url = "github:alexghr/nixpkgs/alexghr/build/update-victor-mono-1.5.3";

  inputs.disko.url = github:nix-community/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs-2305";

  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager-master.url = "github:nix-community/home-manager/master";
  inputs.home-manager-master.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:montchr/agenix/darwin-support";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.alacritty-theme.url = "github:alexghr/alacritty-theme.nix";

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-unstable, nixpkgs-2305, nixpkgs-2211, alexghr-nixpkgs, darwin, home-manager, home-manager-master, vscode-server, agenix, nixos-hardware, alacritty-theme, disko }@attrs: {

    overlays.alexghrNixpkgs = final: prev: {
      alexghrNixpkgs = alexghr-nixpkgs.legacyPackages.x86_64-linux;
    };

    overlays.unstable = final: prev: {
      # assume we're running NixOS on Linux so use its unstable variant
      unstable = if prev.stdenv.isLinux
        then
          import nixos-unstable {
            system = prev.system;
            config.allowUnfree = prev.config.allowUnfree;
          }
        else
          import nixpkgs-unstable {
            system = prev.system;
            config.allowUnfree = prev.config.allowUnfree;
          };
    };

    nixosModules =  builtins.listToAttrs (map (x: {
      name = x;
      value = import (./modules + "/${x}");
    })
    (builtins.attrNames (builtins.readDir ./modules)));

    nixosConfigurations = {
      hk47 = let system = "aarch64-linux"; in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          home-manager.nixosModule
          agenix.nixosModule
          { imports = builtins.attrValues self.nixosModules; }
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/hk47/configuration.nix
          ./users/ag.nix
          vscode-server.nixosModule
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };

      vader = let system = "x86_64-linux"; in nixpkgs-2305.lib.nixosSystem {
        inherit system;
        modules = [
          # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.alexghrNixpkgs
              self.overlays.unstable
              alacritty-theme.overlays.default
            ];
          })
          home-manager-master.nixosModule
          agenix.nixosModule
          { imports = builtins.attrValues self.nixosModules; }
          ./hosts/vader/configuration.nix
          ./users/ag.nix
          vscode-server.nixosModule
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs-2305;
            fonts.fonts = [pkgs.alexghrNixpkgs.victor-mono];
          })
        ];
      };

      nix-1 = let system = "x86_64-linux"; in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.alexghrNixpkgs
              self.overlays.unstable
            ];
          })
          home-manager.nixosModule
          { imports = builtins.attrValues self.nixosModules; }
          ./hosts/nix-1/configuration.nix
          ./users/ag.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };

      b1droid =  nixpkgs-2305.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = attrs;
        modules = [
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            nixpkgs.overlays = [
              (final: prev: {
                # the Clickhouse package in 23.05 doesn't exist in binary caches :(
                clickhouse = nixpkgs-2211.legacyPackages.${prev.system}.clickhouse;
              })
            ];
          })

          disko.nixosModules.disko
          ./hosts/b1droid/configuration.nix
        ];
      };

      implausible = let system = "x86_64-linux"; in nixpkgs-2305.lib.nixosSystem {
        inherit system;
        modules = [
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          agenix.nixosModule
          ./hosts/implausible/configuration.nix
        ];
      };

      webby = let system = "x86_64-linux"; in nixpkgs-2305.lib.nixosSystem {
        inherit system;
        modules = [
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          agenix.nixosModule
          ./hosts/webby/configuration.nix
        ];
      };
    };

    darwinConfigurations = {
      mackey = let system = "aarch64-darwin"; in darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.alexghrNixpkgs
              self.overlays.unstable
              alacritty-theme.overlays.default
            ];
          })
          home-manager.darwinModule
          agenix.darwinModule
          ./modules/home-manager
          ./modules/cachix
          ./modules/system
          ./hosts/mackey/darwin-configuration.nix
          ./users/ag.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            fonts.fonts = [pkgs.victor-mono];
          })
        ];
      };
    };
  };
}
