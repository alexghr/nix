{
  description = "Manage my Nix-based machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.alexghr-nixpkgs.url = "github:alexghr/nixpkgs/alexghr/build/update-victor-mono-1.5.3";

  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:alexghr/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, alexghr-nixpkgs, darwin, home-manager, vscode-server }: {

    overlays.alexghrNixpkgs = final: prev: {
      alexghrNixpkgs = alexghr-nixpkgs.legacyPackages.x86_64-linux;
    };

    nixosModules =  builtins.listToAttrs (map (x: {
      name = x;
      value = import (./modules + "/${x}");
    })
    (builtins.attrNames (builtins.readDir ./modules)));

    nixosConfigurations = {
      vader = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModule
          { imports = builtins.attrValues self.nixosModules; }
          ./hosts/vader/configuration.nix
          ./users/ag.nix
          vscode-server.nixosModule
          # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [self.overlays.alexghrNixpkgs];
          })
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            fonts.fonts = [pkgs.alexghrNixpkgs.victor-mono];
          })
        ];
      };

      nix-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
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
      ishuttle = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModule
          ./hosts/ishuttle/darwin-configuration.nix
        ];
      };
    };
  };
}
