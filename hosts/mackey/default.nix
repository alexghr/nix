{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.darwinConfigurations.mackey =
    withSystem
    "aarch64-darwin"
    (
      ctx @ {
        config,
        system,
        ...
      }:
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;

          specialArgs = {
            packages = config.packages;
            alexghrKeys = self.alexghrKeys;
            darwinModules = self.darwinModules;
          };

          modules = [
            ./darwin-configuration.nix
          ];
        }
    );
}
