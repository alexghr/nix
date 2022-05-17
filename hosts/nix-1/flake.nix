{
  description = "Manage nix-1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.arion.url = "github:hercules-ci/arion/master";

  outputs = { self, nixpkgs, arion }: {
    nixosConfigurations.nix-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        arion.nixosModules.arion
        ./configuration.nix
        ({ pkgs, ... }: {
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
