{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.alacritty-theme = {pkgs, ...}: {
    nixpkgs.overlays = [inputs.alacritty-theme.overlays.default];
  };
}
