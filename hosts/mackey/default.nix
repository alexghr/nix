{
  self,
  inputs,
  ...
}: {
  flake.darwinConfigurations.mackey = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs.darwinModules = self.darwinModules;
    modules = [./configuration.nix];
  };
}
