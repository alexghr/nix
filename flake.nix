{
  description = "Manage my Nix-based machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.disko.url = github:nix-community/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.agenix.inputs.home-manager.follows = "home-manager";
  inputs.agenix.inputs.darwin.follows = "darwin";

  inputs.alacritty-theme.url = "github:alexghr/alacritty-theme.nix";

  inputs.attic.url = "github:zhaofengli/attic";

  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixpkgs-2311, nixpkgs-unstable, darwin, home-manager, agenix, alacritty-theme, disko, attic, vscode-server }@attrs: {

    overlays.unstable = final: prev: {
      unstable = import nixpkgs-unstable {
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
          { imports = builtins.attrValues self.nixosModules; }
          home-manager.nixosModule
          agenix.nixosModules.default
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            nixpkgs.overlays = [
              alacritty-theme.overlays.default
            ];
          })
          ./hosts/hk47/configuration.nix
          ./users/ag.nix
        ];
      };


      palpatine = let system = "x86_64-linux"; in nixpkgs-2311.lib.nixosSystem {
        inherit system;
        modules = [
          # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.unstable
              alacritty-theme.overlays.default
              attic.overlays.default
            ];
          })
          home-manager.nixosModule
          agenix.nixosModules.default
          { imports = builtins.attrValues self.nixosModules; }
          vscode-server.nixosModules.default
          ./hosts/palpatine/configuration.nix
          ./users/ag.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            fonts.fonts = [pkgs.victor-mono];
          })
        ];
      };

      nixosIso = let system = "x86_64-linux"; in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [
              git
              vim
              file
              parted
            ];
          })
        ];
      };

      b1 =  nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          self.nixosModules.attic
          self.nixosModules.tailscale
          disko.nixosModules.disko
          agenix.nixosModules.default
          attic.nixosModules.atticd
          ./hosts/b1/configuration.nix
        ];
      };
    };

    darwinConfigurations = {
      mackey = let system = "aarch64-darwin"; in darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ...}: {
            nixpkgs.overlays = [
              self.overlays.unstable
              alacritty-theme.overlays.default
            ];
          })
          home-manager.darwinModule
          agenix.darwinModules.default
          ./modules/home-manager
          ./modules/cachix
          ./modules/system
          ./modules/attic
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
