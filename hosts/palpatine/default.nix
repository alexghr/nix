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
            alexghrKeys = (import ../../alexghr.keys.nix).ssh;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./configuration.nix
          ];
        }
    );
}
