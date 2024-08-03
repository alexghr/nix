{
  config,
  lib,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
  };
}
