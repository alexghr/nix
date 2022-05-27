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
          ./hosts/vader/configuration.nix
        ];
      };

      nix-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModule
          arion.nixosModules.arion
          ./hosts/nix-1/configuration.nix
          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
            home-manager.useUserPackages = true;
            home-manager.users.ag = import ./hosts/nix-1/home.nix;

            virtualisation = {
              podman.enable = true;
              podman.dockerCompat = true;
              podman.defaultNetwork.dnsname.enable = true;
            };
            users.users.ag.extraGroups = ["podman"];

            services.restic.backups.b2 = {
              passwordFile = "/var/restic/password.txt";
              environmentFile = "/var/restic/b2.env";
              repository = "b2:backups-alexghr-me:/nix-1/";
              paths = [
                "/home"
                "/etc"
                "/var"
              ];

              extraBackupArgs = [
                "--exclude /var/log"
              ];

              initialize = true;
            };
          })
        ];
      };
    };
  };
}
