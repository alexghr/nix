{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.mse-6 =
    withSystem
    "armv6l-linux"
    (
      ctx @ {
        config,
        system,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            packages = config.packages;
            alexghrKeys = self.alexghrKeys;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./mse-6.nix
          ];
        }
    );
}
