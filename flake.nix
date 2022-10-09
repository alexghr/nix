{
  description = "Manage my Nix-based machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.alexghr-nixpkgs.url = "github:alexghr/nixpkgs/alexghr/build/update-victor-mono-1.5.3";

  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:alexghr/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:montchr/agenix/darwin-support";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, nixpkgs, nixpkgs-unstable, alexghr-nixpkgs, darwin, home-manager, vscode-server, agenix, nixos-hardware }: {

    overlays.alexghrNixpkgs = final: prev: {
      alexghrNixpkgs = alexghr-nixpkgs.legacyPackages.x86_64-linux;
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

      vader = let system = "x86_64-linux"; in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.alexghrNixpkgs
              (final: prev: {
                unstable = nixpkgs-unstable.legacyPackages."${system}";
              })
            ];
          })
          home-manager.nixosModule
          agenix.nixosModule
          { imports = builtins.attrValues self.nixosModules; }
          ./hosts/vader/configuration.nix
          ./users/ag.nix
          vscode-server.nixosModule
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
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
              (final: prev: {
                unstable = nixpkgs-unstable.legacyPackages."${system}";
              })
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
    };

    darwinConfigurations = {
      ishuttle = let system = "aarch64-darwin"; in darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.alexghrNixpkgs
              (final: prev: {
                unstable = nixpkgs-unstable.legacyPackages."${system}";
              })
            ];
          })
          home-manager.darwinModule
          agenix.darwinModule
          ./modules/home-manager
          ./modules/cachix
          ./modules/system
          ./hosts/ishuttle/darwin-configuration.nix
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
