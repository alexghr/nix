{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.drk-1 =
    withSystem
    "aarch64-linux"
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
            ./drk-1.nix
          ];
        }
    );
}
