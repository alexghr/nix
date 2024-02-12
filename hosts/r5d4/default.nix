{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.r5d4 =
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
            packages = config.packages;
            alexghrKeys = self.alexghrKeys;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./r5d4.nix
          ];
        }
    );
}
