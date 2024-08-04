{
  inputs,
  lib,
  ...
}: let
  module = {pkgs, ...}: {
    nixpkgs.overlays = [inputs.alacritty-theme.overlays.default];
  };
in {
  flake.nixosModules.alacritty-theme = module;
  flake.darwinModules.alacritty-theme = module;
}
