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
      {system, ...}:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            alexghrKeys = self.alexghrKeys;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./configuration.nix
          ];
        }
    );
}
