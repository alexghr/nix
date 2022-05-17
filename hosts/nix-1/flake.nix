{
  description = "Manage nix-1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.arion.url = "github:hercules-ci/arion/master";
  inputs.home-manager.url = "github:nix-community/home-manager/release-21.11";

  outputs = { self, nixpkgs, arion, home-manager }: {
    nixosConfigurations.nix-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModule
        arion.nixosModules.arion
        ./configuration.nix
        ({ pkgs, ... }: {
          home-manager.useUserPackages = true;
          home-manager.users.ag = import ./home.nix;

          virtualisation = {
            podman.enable = true;
            podman.dockerCompat = true;
            podman.defaultNetwork.dnsname.enable = true;
          };
          users.users.ag.extraGroups = ["podman"];
        })
      ];
    };
  };
}
