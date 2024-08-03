{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.palpatine =
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
            ./configuration.nix
          ];
        }
    );
}
