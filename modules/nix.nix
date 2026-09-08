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
          system = prev.stdenv.hostPlatform.system;
          inherit (prev) config;
        };
        neovim-nightly = inputs.neovim-nightly.packages.${prev.stdenv.hostPlatform.system}.default;
      })
    ];
    nix = {
      package = lib.mkDefault pkgs.nixVersions.stable;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        extra-substituters = ["https://devenv.cachix.org" "https://alexghr.cachix.org"];
        extra-trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "alexghr.cachix.org-1:F8zCrUqEm3m4ThJWsMe+d2RTXGmGNKpM1anvMTQdBP4="
        ];
      };
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    };
  };
in {
  flake.nixosModules.nix = {...}: {
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
  flake.darwinModules.nix = {...}: {
    imports = [module];
    nix.gc.interval = {
      Hour = 12;
      Minute = 0;
      Day = 1; # Monthly
    };
  };
}
