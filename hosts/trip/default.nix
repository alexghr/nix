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
            alexghrKeys = import ../../alexghr.keys.nix;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./trip.nix
          ];
        }
    );
}
