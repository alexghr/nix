{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.iso-x86_64 =
    withSystem
    "x86_64-linux"
    (
      ctx @ {
        config,
        system,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            alexghrKeys = self.alexghrKeys;
          };

          modules = [
            (
              {
                config,
                pkgs,
                alexghrKeys,
                modulesPath,
                lib,
                ...
              }: {
                imports = [
                  "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
                    self.nixosModules.nix
                ];

                boot.kernelPackages = pkgs.linuxPackages_6_1;

                system.stateVersion = "23.11";
                time.timeZone = "Europe/London";

                users.users.nixos.openssh.authorizedKeys.keys = alexghrKeys;

                networking = {
                  hostName = "nixos";
                  networkmanager.enable = true;
                  wireless.enable = false;
                };

                environment.systemPackages = with pkgs; [
                  vim
                  git
                  parted
                ];

                services.openssh.enable = true;
              }
            )
          ];
        }
    );
}
