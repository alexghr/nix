{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.trip =
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
            ./trip.nix
          ];
        }
    );
}
