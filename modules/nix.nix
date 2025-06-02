{
  inputs,
  lib,
  ...
}: let
  module = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
    nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = prev.config.allowUnfree;
        };
        pinned = import inputs.nixpkgs-pinned {
          system = prev.system;
          config.allowUnfree = prev.config.allowUnfree;
        };
      })
    ];
    nix = {
      package = lib.mkDefault pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };

      #settings.substituters = ["https://nixcache.esrever.uno"];
      #settings.trusted-public-keys = ["nixcache.esrever.uno:CyCbXQKNkoSsPISjnHaVY2ag6ZmL0q/8saSdnqEUdFk="];
    };
  };
in {
  flake.nixosModules.nix = {pkgs, ...}: {
    imports = [module];
    nix.gc.dates = "monthly";
    nix.nixPath = [
      "nixpkgs=/etc/nixpkgs/channels/nixpkgs"
      "nixpkgs-unstable=/etc/nixpkgs/channels/nixpkgs-unstable"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    systemd.tmpfiles.rules = [
      "L+ /etc/nixpkgs/channels/nixpkgs - - - - ${inputs.nixpkgs}"
      "L+ /etc/nixpkgs/channels/nixpkgs-unstable - - - - ${inputs.nixpkgs-unstable}"
    ];
  };
  flake.darwinModules.nix = {pkgs, ...}: {
    imports = [module];
    nix.gc.interval = {
      Hour = 12;
      Minute = 0;
      Day = 1; # Monthly
    };
  };
}
