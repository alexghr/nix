{
  description = "Manage my Nix-based machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.arion.url = "github:hercules-ci/arion/master";

  outputs = { self, nixpkgs, home-manager, arion }: {
    nixosConfigurations = {
      vader = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModule
          ./modules/cachix
          ./modules/system-packages.nix
          ./modules/home-manager.nix
          ./hosts/vader/configuration.nix
          ./users/ag.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };

      nix-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModule
          arion.nixosModules.arion
          ./modules/cachix
          ./modules/system-packages.nix
          ./modules/home-manager.nix
          ./hosts/nix-1/configuration.nix
          ./users/ag.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };
    };
  };
}
