{self, ...}: {
  perSystem = {system, ...}: {
    checks =
      if system == "x86_64-linux"
      then {
        palpatine = self.nixosConfigurations.palpatine.config.system.build.toplevel;
        palpatine-vm = self.nixosConfigurations.palpatine.config.system.build.vmWithBootLoader;
        trip = self.nixosConfigurations.trip.config.system.build.toplevel;
        home-palpatine = self.nixosConfigurations.palpatine.config.home-manager.users.ag.home.activationPackage;
      }
      else {
        mackey = self.darwinConfigurations.mackey.system;
        home-mackey = self.darwinConfigurations.mackey.config.home-manager.users.ag.home.activationPackage;
      };
  };
}
