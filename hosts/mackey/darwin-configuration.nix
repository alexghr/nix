{
  pkgs,
  config,
  darwinModules,
  ...
}: {
  imports = [
    darwinModules.agenix
    darwinModules.alacritty-theme
  ];
}
