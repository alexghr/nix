{inputs, ...}: let
  shared = {config, ...}: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # Preserve existing dotfiles during the first migration.
      backupFileExtension = "before-home-manager";
      users.ag = {
        imports = [../home];
        home.username = "ag";
        home.homeDirectory = config.users.users.ag.home;
      };
    };
  };
in {
  flake.nixosModules.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager shared];
  };
  flake.darwinModules.home-manager = {
    imports = [inputs.home-manager.darwinModules.home-manager shared];
  };
}
